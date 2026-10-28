# TripTrack — setup and deployment guide

This is a mobile-friendly online trip registration and attendance web app. It can be added to an Android home screen like an app. It stores registrations online in Supabase, has a public registration link, WhatsApp sharing, organiser sign-in, live totals, check-in controls, search, and CSV export.

## Important
The project code is prepared, but it is **not live yet**. You must create your own Supabase project and deploy the site to receive a real shareable link. Never share your Supabase service-role key. Only the publishable/anon key belongs in the frontend environment variables.

## Part 1 — Create the online database
1. Open https://supabase.com and create/sign in to an account.
2. Create a new project. Give it a name such as `triptrack`, choose a strong database password, and select a nearby region if available. Save your database password privately.
3. When the project finishes, open **SQL Editor** → **New query**.
4. Open the `supabase.sql` file from this project, copy all of it into the SQL Editor, and click **Run**.
5. Go to **Project Settings** → **API** (or **Connect**, depending on the current dashboard layout). Copy the **Project URL** and the **publishable/anon public key**. Do not copy or expose the `service_role` / secret key.

## Part 2 — Create the organiser login
1. In Supabase, open **Authentication** → **Users** → **Add user** / **Create new user**.
2. Enter the organiser's email and a strong password. Confirm the user if the dashboard offers that option.
3. Copy the user's **UID** from the users list.
4. Open **SQL Editor** and run the following statement, replacing the sample UUID with that user's real UID:

```sql
insert into public.trip_admins (user_id)
values ('PASTE-ORGANISER-USER-UID-HERE');
```

Only add trusted organisers. They can view traveller names/phone numbers and mark check-ins.

## Part 3 — Deploy to Netlify (easiest beginner route)
You can do this from a computer. If you only have a phone, the dashboards may be harder to use; a Windows laptop is recommended.

1. Create/sign in at https://github.com and create a new repository named `trip-attendance-tracker`.
2. Upload the contents of this ZIP (the files inside the `trip-attendance-app` folder, not the outer folder) to that repository. Keep `package.json`, `index.html`, `src/`, `supabase.sql`, and `SETUP.md` at the repository root. Do not upload a real `.env` file or secrets.
3. Create/sign in at https://www.netlify.com and choose **Add new site** → **Import an existing project** → connect GitHub → choose `trip-attendance-tracker`.
4. Set the build command to `npm run build` and publish directory to `dist`.
5. In the Netlify site's **Environment variables** settings, add:
   - `VITE_SUPABASE_URL` = your Supabase Project URL
   - `VITE_SUPABASE_ANON_KEY` = your Supabase publishable/anon public key
   - `VITE_TRIP_NAME` = `Sipi Falls Trip 2026` (or your chosen trip name)
   - `VITE_TRIP_DATE` = `2026-11-07` (or your date in YYYY-MM-DD format)
6. Save variables and trigger a new deploy. Wait for Netlify to show **Published**. Open the `https://...netlify.app` site URL. That becomes the registration link.
7. Open the public link, submit one test registration, then open `/ ?admin=1` without the space (append `?admin=1` to the site URL) and sign in with the organiser account. Check that the test registration appears. Delete test records from Supabase Table Editor before sharing widely if needed.

## Part 4 — Share and use it
- On the registration page, tap **Share on WhatsApp** to open WhatsApp with a prepared invitation, or tap **Copy registration link** and paste it into a group.
- Travellers register with their name, phone number, group size, and optional note.
- On the dashboard, the organiser can search by name/phone, tap **Check in**, see totals update, and export a CSV spreadsheet.
- To install it on Android, open the live link in Chrome, tap the browser menu (three dots), then choose **Add to Home screen**. It is a web app shortcut, not a Play Store APK.

## Updating the trip details
Change `VITE_TRIP_NAME` and `VITE_TRIP_DATE` in Netlify environment variables, then redeploy. If you want to change the app code, edit the GitHub repository and Netlify will rebuild it.

## Privacy and safety notes
- Public visitors can submit a registration but cannot view the traveller list.
- Only user IDs manually added to `trip_admins` can view names/phone numbers and update check-in status.
- The phone number is unique in this starter version, so one number cannot register twice. Remove the unique index in `supabase.sql` if you want to allow multiple entries per phone.
- Keep the organiser password private, and only share the dashboard link with trusted organisers. The dashboard path is not the security control; Supabase authentication and database policies are.
- This starter stores the group leader's contact and group size. It does not collect a separate phone number for every person in a group.
