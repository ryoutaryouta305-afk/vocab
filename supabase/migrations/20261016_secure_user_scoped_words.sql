-- Secure vocabulary rows by Supabase Auth user.
-- The words table was verified empty before this migration.
alter table public.words
  add column if not exists user_id uuid references auth.users(id) on delete cascade;

alter table public.words alter column user_id set not null;

alter table public.words
  add constraint words_user_word_lang_key unique (user_id, word, lang);

drop policy if exists "public read" on public.words;
drop policy if exists "secret insert" on public.words;
drop policy if exists "secret update" on public.words;
drop policy if exists "secret delete" on public.words;

create policy "users read own words"
  on public.words for select to authenticated
  using (auth.uid() = user_id);

create policy "users insert own words"
  on public.words for insert to authenticated
  with check (auth.uid() = user_id);

create policy "users update own words"
  on public.words for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "users delete own words"
  on public.words for delete to authenticated
  using (auth.uid() = user_id);

grant select, insert, update, delete on public.words to authenticated;
