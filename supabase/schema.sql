-- ============================================================================
-- PAULEANDERSON | DR. FILMES — banco do painel administrativo
-- ----------------------------------------------------------------------------
-- Como usar: Supabase > SQL Editor > New query > cole tudo e clique em Run.
-- Pode rodar de novo sem medo: cria o que falta e não apaga dados existentes
-- (os preços iniciais só entram se a tabela estiver vazia).
-- ============================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- 1. PERFIS E PERMISSÃO DE ADMIN
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  email      text,
  nome       text,
  is_admin   boolean not null default false,
  criado_em  timestamptz not null default now()
);

-- Todo usuário criado no Auth ganha um perfil (sem permissão de admin).
create or replace function public.criar_perfil()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, nome)
  values (new.id, new.email, coalesce(new.raw_user_meta_data ->> 'nome', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists ao_criar_usuario on auth.users;
create trigger ao_criar_usuario
  after insert on auth.users
  for each row execute function public.criar_perfil();

-- Quem é admin (usada em todas as políticas de escrita).
create or replace function public.eh_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false)
$$;

alter table public.profiles enable row level security;

drop policy if exists "perfil: leio o meu ou tudo se admin" on public.profiles;
create policy "perfil: leio o meu ou tudo se admin" on public.profiles
  for select using (id = auth.uid() or public.eh_admin());

-- Só admin altera perfis. Criar/promover admin é feito por SQL (passo 5 do LEIA-ME).
drop policy if exists "perfil: admin altera" on public.profiles;
create policy "perfil: admin altera" on public.profiles
  for update using (public.eh_admin()) with check (public.eh_admin());

-- ---------------------------------------------------------------------------
-- 2. CATÁLOGO DO CONFIGURADOR DE ORÇAMENTO
--    Uma tabela para os cinco blocos do /monte: evento, duracao, estilo,
--    extra e entrega. `preco` é o valor somado ao orçamento.
-- ---------------------------------------------------------------------------
create table if not exists public.catalogo_itens (
  id              uuid primary key default gen_random_uuid(),
  tipo            text not null check (tipo in ('evento','duracao','estilo','extra','entrega')),
  slug            text not null,
  nome            text not null,
  descricao       text,
  faixa           text,                       -- duração: "8 a 12 minutos"
  grupo           text,                       -- extra: antes / durante / depois
  preco           numeric(10,2) not null default 0,
  ativo           boolean not null default true,
  destaque        boolean not null default false,
  incluido        boolean not null default false,
  sob_consulta    boolean not null default false,
  conflita        text[] not null default '{}',
  icone           text,                       -- evento: alianca, quinze, bolo...
  inclui          text,                       -- estilo: o que a edição entrega
  exemplo_youtube text,
  ordem           int not null default 0,
  criado_em       timestamptz not null default now(),
  atualizado_em   timestamptz not null default now(),
  unique (tipo, slug)
);

alter table public.catalogo_itens enable row level security;

-- O site público lê o que está ativo; o painel lê e escreve tudo.
drop policy if exists "catalogo: leitura publica dos ativos" on public.catalogo_itens;
create policy "catalogo: leitura publica dos ativos" on public.catalogo_itens
  for select using (ativo = true or public.eh_admin());

drop policy if exists "catalogo: admin escreve" on public.catalogo_itens;
create policy "catalogo: admin escreve" on public.catalogo_itens
  for insert with check (public.eh_admin());

drop policy if exists "catalogo: admin atualiza" on public.catalogo_itens;
create policy "catalogo: admin atualiza" on public.catalogo_itens
  for update using (public.eh_admin()) with check (public.eh_admin());

drop policy if exists "catalogo: admin apaga" on public.catalogo_itens;
create policy "catalogo: admin apaga" on public.catalogo_itens
  for delete using (public.eh_admin());

create index if not exists catalogo_itens_tipo_idx on public.catalogo_itens (tipo, ordem);

-- ---------------------------------------------------------------------------
-- 3. BIBLIOTECA DE MÍDIA (referência das fotos enviadas ao Storage)
-- ---------------------------------------------------------------------------
create table if not exists public.midias (
  id         uuid primary key default gen_random_uuid(),
  titulo     text,
  caminho    text not null,        -- ex: casamentos/ana-e-pedro/entrada.jpg
  url        text not null,        -- URL pública no Storage
  mime       text,
  bytes      bigint,
  categoria  text,                 -- casamento / quinze / corporativo / bastidor
  alt        text,
  criado_em  timestamptz not null default now(),
  unique (caminho)
);

alter table public.midias enable row level security;

drop policy if exists "midia: leitura publica" on public.midias;
create policy "midia: leitura publica" on public.midias
  for select using (true);

drop policy if exists "midia: admin escreve" on public.midias;
create policy "midia: admin escreve" on public.midias
  for insert with check (public.eh_admin());

drop policy if exists "midia: admin atualiza" on public.midias;
create policy "midia: admin atualiza" on public.midias
  for update using (public.eh_admin()) with check (public.eh_admin());

drop policy if exists "midia: admin apaga" on public.midias;
create policy "midia: admin apaga" on public.midias
  for delete using (public.eh_admin());

-- ---------------------------------------------------------------------------
-- 4. STORAGE — bucket público "midia" para as fotos do site
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('midia', 'midia', true, 15728640,
        array['image/jpeg','image/png','image/webp','image/avif'])
on conflict (id) do update
  set public = true,
      file_size_limit = 15728640,
      allowed_mime_types = array['image/jpeg','image/png','image/webp','image/avif'];

drop policy if exists "midia: qualquer um baixa" on storage.objects;
create policy "midia: qualquer um baixa" on storage.objects
  for select using (bucket_id = 'midia');

drop policy if exists "midia: admin envia" on storage.objects;
create policy "midia: admin envia" on storage.objects
  for insert with check (bucket_id = 'midia' and public.eh_admin());

drop policy if exists "midia: admin substitui" on storage.objects;
create policy "midia: admin substitui" on storage.objects
  for update using (bucket_id = 'midia' and public.eh_admin());

drop policy if exists "midia: admin remove" on storage.objects;
create policy "midia: admin remove" on storage.objects
  for delete using (bucket_id = 'midia' and public.eh_admin());

-- ---------------------------------------------------------------------------
-- 5. PONTO DE ENTRADA ÚNICO DO CONFIGURADOR (usado pelo /monte)
--    Lê o catálogo já no formato do monte-seu-filme.config.js.
-- ---------------------------------------------------------------------------
create or replace view public.monte_catalogo
with (security_invoker = true) as
select tipo, slug, nome, descricao, faixa, grupo, preco, destaque, incluido,
       sob_consulta, conflita, icone, inclui, exemplo_youtube, ordem
from public.catalogo_itens
where ativo = true
order by tipo, ordem;

-- ---------------------------------------------------------------------------
-- 6. PREÇOS INICIAIS (só entram se o catálogo ainda estiver vazio)
--    Fonte: Calculadora_Preco_Pauleanderson.xlsx, aba Produtos (preço praticado)
--    e o monte-seu-filme.config.js publicado.
-- ---------------------------------------------------------------------------
insert into public.catalogo_itens (tipo, slug, nome, descricao, grupo, preco, destaque, incluido, sob_consulta, conflita, icone, inclui, exemplo_youtube, ordem)
select * from (values
  ('evento','casamento','Casamento','Cerimônia, festa e tudo o que acontece entre elas.', null::text, 9500::numeric, false, false, false, '{}'::text[], 'alianca'::text, null::text, null::text, 1),
  ('evento','quinze','Festa de 15 anos','A entrada, a valsa e a festa da debutante.', null, 6500, false, false, false, '{}', 'quinze', null, null, 2),
  ('evento','infantil','Aniversário infantil','Festa de criança, com o olhar na família.', null, 2500, false, false, false, '{}', 'bolo', null, null, 3),
  ('evento','adulto','Aniversário adulto','Bodas, 40, 50, 60 anos e celebrações íntimas.', null, 2500, false, false, false, '{}', 'brinde', null, null, 4),
  ('evento','formatura','Formatura','Colação, jantar e a festa da turma.', null, 2500, false, false, false, '{}', 'capelo', null, null, 5),
  ('evento','corporativo','Evento corporativo','Confraternização, lançamento, convenção.', null, 3500, false, false, false, '{}', 'predio', null, null, 6),
  ('evento','ensaio','Ensaio especial','Pré-wedding, gestante, família, marca pessoal.', null, 2500, false, false, false, '{}', 'camera', null, null, 7),
  ('evento','outro','Outro evento','Batizado, chá, celebração particular.', null, 2500, false, false, false, '{}', 'calendario', null, null, 8),

  ('duracao','curto','Filme Curto','Um vídeo rápido e emocionante, com os melhores momentos do evento.', '1 a 3 minutos', 0, false, false, false, '{}', null, null, null, 1),
  ('duracao','essencial','Filme Essencial','Uma seleção dos principais momentos, organizada para contar a história do evento.', '5 a 7 minutos', 1500, true, false, false, '{}', null, null, null, 2),
  ('duracao','especial','Filme Especial','Uma história mais completa, com momentos importantes, emoções e detalhes.', '8 a 12 minutos', 3000, false, false, false, '{}', null, null, null, 3),
  ('duracao','completo','Filme Completo','Mais momentos registrados, permitindo reviver diferentes partes da celebração.', '15 a 20 minutos', 5500, false, false, false, '{}', null, null, null, 4),
  ('duracao','documental','Filme Documental','Uma recordação extensa, com acontecimentos, falas, homenagens e momentos especiais.', '25 a 45 minutos', 9000, false, false, false, '{}', null, null, null, 5),

  ('estilo','simples','Edição Simples','Os melhores momentos do seu evento, organizados em um vídeo bonito, com música e transições suaves.', null, 0, false, false, false, '{}', null, 'Seleção de cenas, montagem e trilha sonora.', 'IDsbhTaJNIg', 1),
  ('estilo','cinematografica','Edição Cinematográfica','Seu evento contado como um filme, com uma montagem emocionante, imagens marcantes e música acompanhando cada momento.', null, 1800, false, false, false, '{}', null, 'Montagem narrativa, ritmo musical, tratamento visual e maior atenção aos detalhes.', 'OEUJ3fe3-_8', 2),
  ('estilo','documental','Edição Documental','Uma história mais verdadeira e completa, preservando falas, acontecimentos e emoções do jeito que aconteceram.', null, 2600, false, false, false, '{}', null, 'Narrativa cronológica ou temática, momentos espontâneos, falas e sons reais do evento.', 'HG2aAqjltCQ', 3),

  ('extra','preparativos','Gravação dos preparativos','Cabelo, maquiagem, vestido, os últimos minutos antes.', 'antes', 900, false, false, false, '{}', null, null, null, 1),
  ('extra','entrevista-familiares','Entrevista com familiares','Depoimentos gravados antes da festa, com calma.', 'antes', 950, false, false, false, '{}', null, null, null, 2),
  ('extra','depoimentos','Depoimentos especiais','Pessoas importantes contam o que aquele dia significa.', 'antes', 950, false, false, false, '{}', null, null, null, 3),
  ('extra','mensagem-surpresa','Mensagem surpresa','Uma mensagem gravada em segredo, exibida no evento.', 'antes', 700, false, false, false, '{}', null, null, null, 4),
  ('extra','ensaio-previo','Ensaio em vídeo antes do evento','Um encontro de câmera para vocês se acostumarem com o registro.', 'antes', 1400, false, false, false, '{}', null, null, null, 5),
  ('extra','local-especial','Gravação em local especial','Uma locação escolhida por vocês para abrir o filme.', 'antes', 1100, false, false, false, '{}', null, null, null, 6),
  ('extra','camera-extra','Câmera adicional','Dois olhares ao mesmo tempo: um no palco, outro na plateia.', 'durante', 950, false, false, false, '{}', null, null, null, 7),
  ('extra','drone','Imagens aéreas com drone','Abertura e planos do espaço vistos de cima.', 'durante', 1500, false, false, true, '{}', null, null, null, 8),
  ('extra','cerimonia-completa','Gravação completa da cerimônia','A cerimônia inteira, do início ao fim, sem cortes.', 'durante', 1100, false, false, false, '{}', null, null, null, 9),
  ('extra','homenagens','Homenagens e discursos','Quem subir para falar fica registrado com áudio limpo.', 'durante', 700, false, false, false, '{}', null, null, null, 10),
  ('extra','entrevistas-convidados','Entrevistas com convidados','Recados rápidos de quem estava lá.', 'durante', 850, false, false, false, '{}', null, null, null, 11),
  ('extra','horas-adicionais','Horas adicionais de cobertura','Para quando a festa não quer terminar.', 'durante', 650, false, false, true, '{}', null, null, null, 12),
  ('extra','reels','Vídeo curto para Instagram','Um corte de até 60s pronto para publicar no dia seguinte.', 'depois', 900, false, false, false, '{vertical}', null, null, null, 13),
  ('extra','teaser','Teaser de até 60 segundos','Uma prévia com o melhor do filme, para matar a saudade.', 'depois', 1100, false, false, false, '{}', null, null, null, 14),
  ('extra','vertical','Vídeo vertical para Reels e Stories','O mesmo filme em formato de celular.', 'depois', 750, false, false, false, '{reels}', null, null, null, 15),
  ('extra','horizontal','Versão horizontal para YouTube ou TV','Para assistir na sala, com a família reunida.', 'depois', 650, false, false, false, '{}', null, null, null, 16),
  ('extra','expressa','Entrega expressa','Prioridade na fila de edição, conforme a agenda.', 'depois', 1000, false, false, true, '{}', null, null, null, 17),
  ('extra','video-extra','Vídeo extra com momentos selecionados','Um segundo filme, com o recorte que vocês escolherem.', 'depois', 1200, false, false, false, '{}', null, null, null, 18),

  ('entrega','link','Link privado para assistir e baixar','Galeria fechada, só quem você convidar entra.', null, 0, false, true, false, '{}', null, null, null, 1),
  ('entrega','alta','Arquivos digitais em alta qualidade','O filme no melhor formato, sem compressão.', null, 0, false, true, false, '{}', null, null, null, 2),
  ('entrega','redes','Versão preparada para redes sociais','Arquivo leve, do jeito que o Instagram gosta.', null, 0, false, true, false, '{}', null, null, null, 3),
  ('entrega','duplo','Versões horizontal e vertical','Os dois formatos, sem precisar pedir depois.', null, 0, false, true, false, '{}', null, null, null, 4),
  ('entrega','pendrive','Pendrive personalizado em madeira','Para guardar fora da nuvem e entregar de presente.', null, 350, false, false, false, '{}', null, null, null, 5)
) as v(tipo, slug, nome, descricao, grupo, preco, destaque, incluido, sob_consulta, conflita, icone, inclui, exemplo_youtube, ordem)
where not exists (select 1 from public.catalogo_itens);

-- Se a tabela já existia antes da v2, acrescente as duas colunas novas:
-- alter table public.catalogo_itens add column if not exists icone text;
-- alter table public.catalogo_itens add column if not exists inclui text;

-- ---------------------------------------------------------------------------
-- 7. DEPOIS DE CRIAR SEU USUÁRIO NO AUTH, torne-o admin (troque o e-mail):
--    update public.profiles set is_admin = true where email = 'seu@email.com';
-- ---------------------------------------------------------------------------
