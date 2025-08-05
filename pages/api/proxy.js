// API route to proxy requests to your Hetzner server
// This helps bypass CORS and company restrictions

export default async function handler(req, res) {
  const { method, body } = req;
  const { serverUrl, endpoint } = req.query;

  if (!serverUrl) {
    return res.status(400).json({ error: 'Server URL is required' });
  }

  try {
    const targetUrl = `${serverUrl}${endpoint || ''}`;
    
    const response = await fetch(targetUrl, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Hetzner-Dashboard-Proxy',
      },
      body: method !== 'GET' ? JSON.stringify(body) : undefined,
    });

    const data = await response.text();
    
    res.status(response.status).json({
      success: response.ok,
      data,
      status: response.status,
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to connect to server',
      message: error.message,
    });
  }
}
