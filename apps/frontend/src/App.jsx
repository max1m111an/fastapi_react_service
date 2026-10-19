import { useEffect, useState } from 'react';

const initialForm = { username: '', email: '', password: '' };

export default function App() {
  const [backend, setBackend] = useState('checking…');
  const [form, setForm] = useState(initialForm);
  const [result, setResult] = useState(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    fetch('/hello')
      .then((response) => (response.ok ? response.json() : Promise.reject(new Error(response.status))))
      .then((data) => setBackend(data.message))
      .catch(() => setBackend('backend unavailable'));
  }, []);

  const onChange = (event) => {
    const { name, value } = event.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const onSubmit = async (event) => {
    event.preventDefault();
    setBusy(true);
    setResult(null);
    try {
      const response = await fetch('/api/v1/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });
      const data = await response.json();
      setResult({ ok: response.ok, text: response.ok ? `User #${data.user_id} created` : data.detail });
      if (response.ok) setForm(initialForm);
    } catch (error) {
      setResult({ ok: false, text: String(error) });
    } finally {
      setBusy(false);
    }
  };

  return (
    <main className="container">
      <h1>fastapi_react_service</h1>
      <p className="status">
        Backend: <strong>{backend}</strong>
      </p>

      <section className="card">
        <h2>Add user</h2>
        <form onSubmit={onSubmit}>
          <input name="username" placeholder="username" value={form.username} onChange={onChange} required />
          <input name="email" type="email" placeholder="email" value={form.email} onChange={onChange} required />
          <input name="password" type="password" placeholder="password" value={form.password} onChange={onChange} required />
          <button type="submit" disabled={busy}>
            {busy ? 'Sending…' : 'Create'}
          </button>
        </form>
        {result && <p className={result.ok ? 'ok' : 'error'}>{result.text}</p>}
      </section>

      <p>
        <a href="/docs">API docs</a>
      </p>
    </main>
  );
}
