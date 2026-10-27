-- COMPTES UTILISATEURS — à coller dans Supabase > SQL Editor > Run (une seule fois)

-- 1) Pseudos
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  pseudo text not null check (char_length(pseudo) between 2 and 30),
  created_at timestamptz not null default now()
);
create unique index if not exists profiles_pseudo_uq on public.profiles (lower(pseudo));
alter table public.profiles enable row level security;
create policy "pseudos lisibles" on public.profiles for select to anon, authenticated using (true);
create policy "creer mon pseudo" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "modifier mon pseudo" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- 2) Auteur réel des partages et commentaires
alter table public.shared_recipes add column if not exists user_id uuid references auth.users(id) on delete set null default auth.uid();
alter table public.recipe_comments add column if not exists user_id uuid references auth.users(id) on delete set null default auth.uid();

-- 3) Droits : lecture pour tous, écriture réservée aux comptes connectés, chacun gère les siens
drop policy if exists "tout le monde lit" on public.shared_recipes;
drop policy if exists "tout le monde publie" on public.shared_recipes;
drop policy if exists "tout le monde lit les commentaires" on public.recipe_comments;
drop policy if exists "tout le monde commente" on public.recipe_comments;

create policy "lecture publique" on public.shared_recipes for select to anon, authenticated using (true);
create policy "publier connecte" on public.shared_recipes for insert to authenticated with check (user_id = auth.uid());
create policy "supprimer mes partages" on public.shared_recipes for delete to authenticated using (user_id = auth.uid());

create policy "lecture publique" on public.recipe_comments for select to anon, authenticated using (true);
create policy "commenter connecte" on public.recipe_comments for insert to authenticated with check (user_id = auth.uid());
create policy "modifier mes commentaires" on public.recipe_comments for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "supprimer mes commentaires" on public.recipe_comments for delete to authenticated using (user_id = auth.uid());

-- 4) Synchronisation des recettes enregistrées, courses, frigo entre appareils
create table if not exists public.user_data (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  data jsonb not null check (pg_column_size(data) < 1000000),
  updated_at timestamptz not null default now()
);
alter table public.user_data enable row level security;
create policy "mes donnees lecture" on public.user_data for select to authenticated using (user_id = auth.uid());
create policy "mes donnees ajout" on public.user_data for insert to authenticated with check (user_id = auth.uid());
create policy "mes donnees maj" on public.user_data for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "mes donnees suppression" on public.user_data for delete to authenticated using (user_id = auth.uid());
