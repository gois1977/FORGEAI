// Forge provider proxy — Cloudflare Worker (optional).
// Use it only if your host blocks direct browser calls to AI providers.
// Deploy:  cd proxy && npx wrangler deploy
// Then paste the Worker URL into Forge > Dashboard > API keys > "Backend proxy".

const ALLOWED_HOSTS = [
  'api.openai.com',
  'api.anthropic.com',
  'generativelanguage.googleapis.com',
  'openrouter.ai',
  'api.groq.com',
  'api.deepseek.com',
  'api.mistral.ai',
  'api.x.ai',
];

export default {
  async fetch(req, env) {
    const allow = (env && env.ALLOWED_ORIGIN) || '*';
    const cors = {
      'Access-Control-Allow-Origin': allow,
      'Access-Control-Allow-Headers': 'content-type',
      'Access-Control-Allow-Methods': 'POST,OPTIONS',
      'Vary': 'Origin',
    };
    if (req.method === 'OPTIONS') return new Response(null, { headers: cors });
    if (req.method !== 'POST') return new Response('POST only', { status: 405, headers: cors });
    if (allow !== '*' && req.headers.get('Origin') !== allow) {
      return new Response('origin not allowed', { status: 403, headers: cors });
    }
    let job;
    try { job = await req.json(); } catch { return new Response('bad json', { status: 400, headers: cors }); }
    let u;
    try { u = new URL(job.url); } catch { return new Response('bad url', { status: 400, headers: cors }); }
    if (u.protocol !== 'https:' || !ALLOWED_HOSTS.includes(u.hostname)) {
      return new Response('host not allowed', { status: 403, headers: cors });
    }
    const method = String(job.method || 'GET').toUpperCase();
    const r = await fetch(u.toString(), {
      method,
      headers: job.headers || {},
      body: method === 'GET' || method === 'HEAD' ? undefined : job.body,
    });
    return new Response(r.body, {
      status: r.status,
      headers: { ...cors, 'Content-Type': r.headers.get('Content-Type') || 'application/json' },
    });
  },
};
