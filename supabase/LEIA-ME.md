# Painel administrativo — Supabase

Login, banco do catálogo e upload de fotos do site. Nada aqui precisa de
servidor próprio: o `admin.html` fala direto com o Supabase, e quem manda no
que pode ser lido ou escrito são as políticas de RLS do banco.

## 1. Criar o projeto

1. Entre em <https://supabase.com/dashboard> e crie um projeto (plano free).
2. Anote dois dados de **Project Settings → API**:
   - **Project URL** — `https://xxxxx.supabase.co`
   - **anon public** — a chave longa que começa com `eyJ…`
3. Nunca copie a chave `service_role` para o site.

## 2. Criar o banco

1. No painel do Supabase, abra **SQL Editor → New query**.
2. Cole todo o conteúdo de `supabase/schema.sql` e clique em **Run**.
3. Ele cria: `profiles` (quem é admin), `catalogo_itens` (preços do `/monte`),
   `midias` (registro das fotos), o bucket público `midia` e as políticas de
   acesso. Rodar de novo não duplica nem apaga nada.

## 3. Criar seu usuário

1. **Authentication → Users → Add user** — e-mail e senha, marque
   *Auto Confirm User*.
2. Volte ao **SQL Editor** e promova esse usuário a administrador:

```sql
update public.profiles set is_admin = true where email = 'seu@email.com';
```

Sem esse passo o login funciona, mas o painel abre só para leitura.

## 4. Conectar o site

Edite `admin-config.js` na raiz do repositório:

```js
window.ADMIN_CONFIG = {
  supabaseUrl: 'https://xxxxx.supabase.co',
  supabaseAnonKey: 'eyJ...',
  bucket: 'midia'
};
```

A chave `anon` pode ficar no repositório: sozinha ela não escreve nada, porque
todas as escritas exigem `is_admin`. Faça commit e o deploy publica
`/admin.html`.

## 5. Usar

- **`/admin.html`** — login, catálogo e fotos. Não está linkado em nenhum menu.
- **Catálogo do orçamento** — edita nome, descrição, preço, ordem e visibilidade
  dos itens que aparecem no `/monte`.
- **Fotos e mídia** — envia JPG/PNG/WEBP (até 15 MB) para o bucket `midia`,
  mostra a grade e copia a URL pública de cada foto.
- **Gerar config** — baixa um `monte-seu-filme.config.js` novo, já com os preços
  do banco, preservando marca, pagamento e desconto do arquivo atual.
  Substitua o arquivo no repositório, faça commit, e o site passa a usar os
  valores novos.

## O que ainda não está automático

O site é estático: o `/monte` lê o `monte-seu-filme.config.js` do próprio
repositório. Por isso a publicação é *baixar o config → substituir → commit*.
Um próximo passo possível é o `/monte` ler direto a view `monte_catalogo` do
Supabase, aí a edição vale no instante em que você salva (sem deploy).
