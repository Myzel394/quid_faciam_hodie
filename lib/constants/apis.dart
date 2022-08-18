import 'dart:convert';

// Encode keys to base64 to avoid simple bots from scraping them
final SUPABASE_API_URL = String.fromCharCodes(
  base64.decode(
    'aHR0cHM6Ly9nbXF6ZWx' + '2YXVxeml1cmxsb2F3Yi5zdXBhYmFzZS5jbwo=',
  ),
);
final SUPABASE_API_KEY = String.fromCharCodes(
  base64.decode(
    'ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnBjM01pT2lKemRYQmhZbUZ6' +
        'WlNJc0luSmxaaUk2SW1kdGNYcGxiSFpoZFhGNmFYVnliR3h2WVhkaUlpd2ljbTlzWlNJNkltRnVi' +
        'MjRpTENKcFlYUWlPakUyTmpBek9ERTVNRGNzSW1WNGNDSTZNVGszTlRrMU56a3dOMzAuRF85NjRF' +
        'SWxEOVdSRm5HNk1XdFF0bUlnMDRlTUJiWmhJRUY3emwtLWJLdwo=',
  ),
);
final PEXELS_API_KEY = String.fromCharCodes(
  base64.decode(
    'NTYz' +
        'NDkyYW' +
        'Q2ZjkxNzAwMDAxM' +
        'DAwMDAxYzE2ODA' +
        '0MGU2NjkzNGNlMT' +
        'kzNjdmZjA5NGU2NDMyM2IK',
  ),
);
