-- Commentaires sur les recettes partagées (à coller dans Supabase > SQL Editor > Run)
create table public.recipe_comments (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  recipe_id uuid not null references public.shared_recipes(id) on delete cascade,
  author text not null default '' check (char_length(author) <= 40),
  body text not null check (char_length(body) between 1 and 600)
);
alter table public.recipe_comments enable row level security;
create policy "tout le monde lit les commentaires" on public.recipe_comments for select to anon using (true);
create policy "tout le monde commente" on public.recipe_comments for insert to anon with check (true);
