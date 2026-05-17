#!/usr/bin/env bun
/**
 * feishu-bridge.ts — Feishu ↔ OMP 消息桥接
 *
 * 轮询飞书 P2P 聊天的新消息，传给 OMP 处理，回复到飞书。
 * 跑在 esl 容器里，用 bot 身份。
 */

import { $ } from "bun";

// -- 配置 ---------------------------------------------------
const CHAT_ID = "oc_ce96c2bddeedd755ea319429a9639e95";
const USER_OPEN_ID = "ou_f3c85b00317c27296578106cebf6acc8";
const POLL_INTERVAL_MS = 3000;
const HOME = process.env.HOME!;
const LARK_CLI = `${HOME}/.bun/bin/lark-cli`;
const OMP = `${HOME}/.bun/bin/omp`;
const TEMP_DIR = `${HOME}/tmp`;

const processed = new Set<string>();
let lastPollTime = Date.now();

// -- Lark CLI 调用封装 --------------------------------------

interface LarkResponse<T = unknown> {
  code: number;
  msg?: string;
  data?: T;
}

async function larkApi<T = unknown>(
  method: string,
  path: string,
  params?: Record<string, string>,
  body?: Record<string, unknown>,
): Promise<LarkResponse<T> | null> {
  const args = [LARK_CLI, "api", method, path, "--as", "bot"];
  if (params) args.push("--params", JSON.stringify(params));
  if (body) args.push("--data", JSON.stringify(body));

  const proc = Bun.spawnSync(args, {
    env: {
      ...process.env,
      PATH: `${HOME}/.bun/bin:${process.env.PATH || ""}`,
      TMPDIR: TEMP_DIR,
    },
  });
  const stdout = proc.stdout.toString().trim();
  const stderr = proc.stderr.toString().trim();

  if (!stdout) {
    console.error("[api] empty response:", stderr.slice(0, 200));
    return null;
  }

  try {
    return JSON.parse(stdout) as LarkResponse<T>;
  } catch {
    console.error("[api] parse error:", stdout.slice(0, 200));
    return null;
  }
}

// -- 飞书消息操作 -------------------------------------------

interface MessageItem {
  message_id: string;
  sender: { id: string; sender_type: string };
  msg_type: string;
  body: { content: string };
  create_time: string;
}

async function getRecentMessages(): Promise<MessageItem[]> {
  const res = await larkApi<{ items: MessageItem[] }>(
    "GET",
    "/open-apis/im/v1/messages",
    {
      container_id_type: "chat",
      container_id: CHAT_ID,
      page_size: "5",
      sort_type: "ByCreateTimeDesc",
    },
  );
  return res?.data?.items ?? [];
}

/**
 * 清理 markdown，去掉极少数飞书卡片不兼容的语法。
 */
function cleanMarkdown(text: string): string {
  return text
    // 行内代码 `code` -> **code**（飞书卡片不支持反引号和斜体，用粗体代替）
    .replace(/`([^`\n]+)`/g, "**$1**")
    // 合并多余空行
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

async function sendFeishu(text: string) {
  const clean = cleanMarkdown(text);
  const card = {
    config: { wide_screen_mode: true },
    header: {
      title: { tag: "plain_text", content: "OMP" },
    },
    elements: [{ tag: "markdown", content: clean }],
  };
  return larkApi("POST", "/open-apis/im/v1/messages", {
    receive_id_type: "chat_id",
  }, {
    receive_id: CHAT_ID,
    msg_type: "interactive",
    content: JSON.stringify(card),
  });
}
/** 给消息加THUMBSUP表示已收到 */
async function addReaction(messageId: string) {
  return larkApi("POST", `/open-apis/im/v1/messages/${messageId}/reactions`, undefined, {
    reaction_type: { emoji_type: "THUMBSUP" },
  });
}

// -- OMP 调用 -----------------------------------------------

async function callOmp(prompt: string): Promise<string> {
  const proc = Bun.spawnSync([OMP, "--print", prompt], {
    env: {
      ...process.env,
      PATH: `${HOME}/.bun/bin:${process.env.PATH || ""}`,
      TMPDIR: TEMP_DIR,
    },
    timeout: 180_000,
  });

  if (proc.exitCode !== 0) {
    const stderr = proc.stderr.toString().trim();
    console.error("[omp] error:", stderr.slice(0, 300));
    return `OMP 处理出错 (exit ${proc.exitCode})`;
  }

  const out = proc.stdout.toString().trim();
  return out || "OMP 处理完成";
}

// -- 从消息中提取用户文本 ------------------------------------

function extractUserText(msg: MessageItem): string | null {
  if (msg.sender?.sender_type !== "user") return null;
  if (msg.sender?.id !== USER_OPEN_ID) return null;
  if (msg.msg_type !== "text") return null;

  try {
    const parsed = JSON.parse(msg.body?.content ?? "{}");
    return (parsed.text ?? "").trim();
  } catch {
    return (msg.body?.content ?? "").trim() || null;
  }
}

// -- 主循环 -------------------------------------------------

async function main() {
  console.log("Feishu OMP Bridge v0.1");
  console.log(`Chat: ${CHAT_ID}, User: ${USER_OPEN_ID}\n`);

  await sendFeishu("OMP 桥接已就绪，可以发消息了");

  while (true) {
    try {
      const items = await getRecentMessages();

      for (const msg of items) {
        const msgId = msg.message_id;
        if (!msgId || processed.has(msgId)) continue;
        processed.add(msgId);

        const text = extractUserText(msg);
        if (!text) continue;

        const createTime = parseInt(msg.create_time ?? "0", 10);
        if (createTime < lastPollTime - 10_000) continue;

        console.log(`\n[<-] "${text.slice(0, 120)}"`);
        // 加个THUMBSUP表示已收到
        await addReaction(msgId).catch(() => {});

        const t0 = Date.now();
        const response = await callOmp(text);
        const elapsed = ((Date.now() - t0) / 1000).toFixed(1);
        console.log(`[->] OMP (${elapsed}s)`);

        await sendFeishu(response);
        console.log(`[->] 已回复飞书`);
      }

      lastPollTime = Date.now();
    } catch (err) {
      console.error("[!]", err);
    }

    await Bun.sleep(POLL_INTERVAL_MS);
  }
}

main().catch((err) => {
  console.error("[FATAL]", err);
  process.exit(1);
});
