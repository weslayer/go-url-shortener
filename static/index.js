document.getElementById('shorten-form').addEventListener('submit', async function (e) {
    e.preventDefault();

    const longUrl = document.getElementById('long-url').value;
    const userId = document.getElementById('user-id').value;

    const response = await fetch('/create-short-url', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ long_url: longUrl, user_id: userId })
    });

    const result = await response.json();

    if (response.ok) {
        document.getElementById('short-url').innerText = `Short URL: ${result.short_url}`;
    } else {
        document.getElementById('short-url').innerText = `Error: ${result.error}`;
    }
});
