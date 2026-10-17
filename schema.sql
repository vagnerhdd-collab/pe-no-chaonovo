-- Rode no Supabase: SQL Editor > New query > cole tudo > Run

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  plan_status text not null default 'free',      -- free | pending | authorized | paused | cancelled
  mp_preapproval_id text,
  access_until timestamptz,                    -- acesso pago avulso (PIX) válido até
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Uma sessão = uma ideia testada (pelo site ou pelo WhatsApp)
create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,   -- quem usou pelo site
  phone text,                                                 -- quem usou pelo WhatsApp
  canal text not null default 'site',                         -- site | whatsapp
  mode text not null default 'negocio',
  idea text not null,
  messages jsonb not null default '[]'::jsonb,
  verdict jsonb,
  score int,
  setor text,
  municipio text,
  uf text,
  created_at timestamptz not null default now()
);
create index if not exists sessions_user_created on public.sessions(user_id, created_at desc);
create index if not exists sessions_phone_created on public.sessions(phone, created_at desc);

-- Estado da conversa de cada número no WhatsApp
create table if not exists public.wa_users (
  phone text primary key,
  name text,
  state text not null default 'menu',     -- menu | idea | chat
  mode text not null default 'negocio',
  session_id uuid references public.sessions(id) on delete set null,
  busy_until timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Pagamentos do passe avulso já processados (evita liberar duas vezes)
create table if not exists public.payments (
  id text primary key,
  user_id uuid references auth.users(id) on delete cascade,
  amount numeric,
  created_at timestamptz not null default now()
);

-- Evita responder duas vezes a mesma mensagem (o WhatsApp reenvia às vezes)
create table if not exists public.wa_messages (
  id text primary key,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Segurança: cada usuário só lê o que é dele. O resto é feito pelo servidor.
alter table public.profiles enable row level security;
alter table public.sessions enable row level security;
alter table public.wa_users enable row level security;
alter table public.wa_messages enable row level security;
alter table public.payments enable row level security;

drop policy if exists "ler proprio perfil" on public.profiles;
create policy "ler proprio perfil" on public.profiles for select using (auth.uid() = id);

drop policy if exists "ler proprias sessoes" on public.sessions;
create policy "ler proprias sessoes" on public.sessions for select using (auth.uid() = user_id);
