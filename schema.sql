-- Run in Supabase SQL Editor
create table if not exists records(
  user_id uuid not null references auth.users on delete cascade default auth.uid(),
  kind text not null, key text not null, data jsonb not null,
  updated_at timestamptz not null default now(),
  primary key(user_id,kind,key));
alter table records enable row level security;
create policy "own rows" on records for all using(auth.uid()=user_id) with check(auth.uid()=user_id);
insert into storage.buckets(id,name,public) values('media','media',false) on conflict do nothing;
create policy "own files read" on storage.objects for select using(bucket_id='media' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "own files write" on storage.objects for insert with check(bucket_id='media' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "own files update" on storage.objects for update using(bucket_id='media' and (storage.foldername(name))[1]=auth.uid()::text);
