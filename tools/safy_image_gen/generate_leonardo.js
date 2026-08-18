#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 安心企業研修Safy ブランディング画像 一括生成ツール(Leonardo.ai版)
// [leonardo-ai-image-gen]スキルのパターンを流用。Card Crown等のキャラ/カードアートとは異なり、
// バリエーション不要の固定5枚(アプリアイコン+オンボーディング3枚+ストアフィーチャーグラフィック)。
//
// コスト最小化: alchemy:false, photoReal:false, num_images:1(スキル鉄則どおり)
// 既存ファイルは自動スキップ(--forceで上書き)
//
// 使い方:
//   $env:LEONARDO_API_KEY = [Environment]::GetEnvironmentVariable("LEONARDO_API_KEY","User")
//   node generate_leonardo.js --all
//   node generate_leonardo.js --ids app_icon,onboarding_1
//   node generate_leonardo.js --all --force
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const fs = require('fs');
const path = require('path');

const LEONARDO_API_KEY = process.env.LEONARDO_API_KEY;
const LEONARDO_MODEL_ID = process.env.LEONARDO_MODEL_ID || 'de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3';
const API_BASE = 'https://cloud.leonardo.ai/api/rest/v1';

// BtoBトーン共通のスタイル指定(設計書Step5.5: 落ち着いたコーポレートカラー・装飾控えめ)
const STYLE_SUFFIX =
  'flat corporate illustration style, minimal and clean, calm professional tone, ' +
  'muted blue color palette (#2D5F7C navy blue as primary accent), soft rounded shapes, ' +
  'no text, no logos, no watermark, simple geometric background, ' +
  'business/office setting, trustworthy and reassuring mood, vector-illustration look';

const NEGATIVE_PROMPT =
  'text, watermark, logo, signature, low quality, blurry, cartoonish, childish, ' +
  'cute mascot, chibi, photorealistic, dark or scary mood, clutter, busy background, ' +
  'extra limbs, deformed hands';

const IMAGES = [
  {
    id: 'app_icon',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'branding', 'app_icon.png'),
    width: 1024,
    height: 1024,
    prompt:
      'A simple flat icon of a shield with a checkmark inside, symbolizing security and trust ' +
      'for a corporate training app, centered composition, single focal object, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'onboarding_1_industry',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'onboarding', 'onboarding_1_industry.png'),
    width: 1024,
    height: 1024,
    prompt:
      'A flat illustration showing a small office building with several category icons ' +
      '(shield, lock, document) automatically highlighted around it, representing an app ' +
      'that selects relevant training topics based on industry type, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'onboarding_2_microlearning',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'onboarding', 'onboarding_2_microlearning.png'),
    width: 1024,
    height: 1024,
    prompt:
      'A flat illustration of a business person casually studying on a smartphone during a ' +
      'short break, with a small clock icon nearby suggesting just a few minutes of learning, ' +
      'commute or office break room setting, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'onboarding_3_certificate',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'onboarding', 'onboarding_3_certificate.png'),
    width: 1024,
    height: 1024,
    prompt:
      'A simple flat icon illustration of a blank document with a large circular checkmark seal ' +
      'stamped on top, abstract icon style with no visible writing or letters on the document, ' +
      'symbolizing an official completion record, single centered focal object, ' +
      STYLE_SUFFIX,
  },
  // --- 6カテゴリのバッジアイコン(category_badge.dartで表示) ---
  {
    id: 'category_info_morals',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'categories', 'category_info_morals.png'),
    width: 512,
    height: 512,
    prompt:
      'A simple flat icon of a group of three people silhouettes standing together, ' +
      'symbolizing digital ethics and good conduct in the workplace, single centered icon, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'category_security',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'categories', 'category_security.png'),
    width: 512,
    height: 512,
    prompt:
      'A simple flat icon of a shield with a padlock in the center, symbolizing information ' +
      'security, single centered icon, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'category_privacy',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'categories', 'category_privacy.png'),
    width: 512,
    height: 512,
    prompt:
      'A simple flat icon of a padlock overlaid on a small person silhouette card, ' +
      'symbolizing personal data protection, single centered icon, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'category_info_management',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'categories', 'category_info_management.png'),
    width: 512,
    height: 512,
    prompt:
      'A simple flat icon of a filing cabinet or stacked document folders with a small database ' +
      'cylinder icon, symbolizing information management, single centered icon, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'category_compliance',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'categories', 'category_compliance.png'),
    width: 512,
    height: 512,
    prompt:
      'A simple flat icon of a judge gavel next to a balanced scale of justice, ' +
      'symbolizing corporate compliance, single centered icon, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'category_ai_usage',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'categories', 'category_ai_usage.png'),
    width: 512,
    height: 512,
    prompt:
      'A simple flat icon of a friendly rounded robot head with a small circuit pattern, ' +
      'symbolizing AI usage in business, single centered icon, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'store_feature_graphic',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'branding', 'store_feature_graphic.png'),
    width: 1024,
    height: 576, // Google Play feature graphic(1024x500)に近い比率。書き出し後に1024x500へクロップする
    prompt:
      'A wide banner illustration for a business training app, showing a small group of ' +
      'diverse office workers with a shield and checklist icon floating above them, ' +
      'wide horizontal composition, ' +
      STYLE_SUFFIX,
  },
  // --- 空状態イラスト(社員未登録・モジュール未受講) ---
  {
    id: 'empty_state_no_employees',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'empty_states', 'empty_state_no_employees.png'),
    width: 512,
    height: 512,
    prompt:
      'A simple flat illustration of an empty office desk with a single empty chair, ' +
      'suggesting no team members have joined yet, calm and inviting rather than sad, ' +
      STYLE_SUFFIX,
  },
  {
    id: 'empty_state_no_modules',
    outFile: path.join(__dirname, '..', '..', 'assets', 'images', 'empty_states', 'empty_state_no_modules.png'),
    width: 512,
    height: 512,
    prompt:
      'A simple flat illustration of a blank open notebook or checklist with a small pencil, ' +
      'suggesting no training content has been assigned yet, calm and inviting rather than sad, ' +
      STYLE_SUFFIX,
  },
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Leonardo.ai 呼び出し(コスト最小設定)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
async function generateImage(prompt, negativePrompt, width, height) {
  const createRes = await fetch(`${API_BASE}/generations`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${LEONARDO_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      prompt,
      negative_prompt: negativePrompt,
      modelId: LEONARDO_MODEL_ID,
      width,
      height,
      num_images: 1,
      alchemy: false,
      photoReal: false,
    }),
  });

  if (!createRes.ok) {
    throw new Error(`Leonardo API error (create): ${createRes.status} ${await createRes.text()}`);
  }

  const created = await createRes.json();
  const genId = created?.sdGenerationJob?.generationId;
  if (!genId) {
    throw new Error(`generationId が取得できませんでした: ${JSON.stringify(created)}`);
  }

  let attempts = 0;
  let images = null;
  while (attempts < 30) {
    await new Promise((r) => setTimeout(r, 2000));
    const poll = await fetch(`${API_BASE}/generations/${genId}`, {
      headers: { Authorization: `Bearer ${LEONARDO_API_KEY}` },
    });
    if (!poll.ok) {
      throw new Error(`Leonardo API error (poll): ${poll.status} ${await poll.text()}`);
    }
    const data = await poll.json();
    const gen = data.generations_by_pk;
    if (gen?.status === 'COMPLETE') {
      images = gen.generated_images;
      break;
    }
    if (gen?.status === 'FAILED') {
      throw new Error(`generation failed: ${JSON.stringify(gen)}`);
    }
    attempts++;
  }

  if (!images || !images[0]?.url) {
    throw new Error('画像生成がタイムアウトしました');
  }

  return images[0].url;
}

async function downloadTo(url, filePath) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`download failed: ${res.status}`);
  const buf = Buffer.from(await res.arrayBuffer());
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, buf);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLI
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { ids: null, all: false, force: false };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--ids') opts.ids = args[++i].split(',').map((s) => s.trim());
    else if (args[i] === '--all') opts.all = true;
    else if (args[i] === '--force') opts.force = true;
  }
  return opts;
}

async function main() {
  if (!LEONARDO_API_KEY) {
    console.error('❌ LEONARDO_API_KEY が設定されていません。');
    console.error('   例: $env:LEONARDO_API_KEY="xxxx"; node generate_leonardo.js --all');
    process.exit(1);
  }

  const opts = parseArgs();
  let target = opts.ids ? IMAGES.filter((img) => opts.ids.includes(img.id)) : IMAGES;

  if (target.length === 0) {
    console.error('❌ 対象画像が見つかりません(--ids の指定を確認してください)');
    process.exit(1);
  }

  let skipped = 0;
  const toGenerate = opts.force
    ? target
    : target.filter((img) => {
        const exists = fs.existsSync(img.outFile);
        if (exists) skipped++;
        return !exists;
      });

  if (skipped > 0) {
    console.log(`⏭️  既存の${skipped}枚をスキップ(再生成するには --force を付けてください)`);
  }
  console.log(`🎨 ${toGenerate.length} 枚を生成します(Leonardo.ai / modelId=${LEONARDO_MODEL_ID} / alchemy=off)\n`);

  for (const img of toGenerate) {
    process.stdout.write(`  ${img.id} (${img.width}x${img.height}) ... `);
    try {
      const imageUrl = await generateImage(img.prompt, NEGATIVE_PROMPT, img.width, img.height);
      await downloadTo(imageUrl, img.outFile);
      console.log(`✅ -> ${img.outFile}`);
    } catch (e) {
      console.log(`❌ ${e.message}`);
    }
  }

  console.log(`\n完了(生成${toGenerate.length}枚 / スキップ${skipped}枚)。`);
}

main().catch((e) => {
  console.error(`❌ 予期しないエラー: ${e.message}`);
  process.exit(1);
});
