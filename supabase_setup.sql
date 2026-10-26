-- À coller dans Supabase > SQL Editor > Run
create table public.shared_recipes (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  author text not null default '' check (char_length(author) <= 40),
  comment text not null default '' check (char_length(comment) <= 600),
  payload jsonb not null check (pg_column_size(payload) < 60000)
);
alter table public.shared_recipes enable row level security;
create policy "tout le monde lit" on public.shared_recipes for select to anon using (true);
create policy "tout le monde publie" on public.shared_recipes for insert to anon with check (true);
-- Pas de policy update/delete : seul toi (tableau de bord) peux supprimer une recette.
