# 🎈 WordNinja

A fast-paced **balloon-popping typing game** that helps you learn English vocabulary. Words float up on balloons — type them before they hit the spikes! Built with **Flutter** and **Supabase**, with Bangla meanings for every word.

---

## ✨ Features

### 🎮 Game Modes
- **Word Pop (Easy)** – Type the word on each balloon to pop it before it reaches the spikes.
- **Synonym Pop (Advanced)** – Pop a *mother balloon* and it bursts into up to **3 synonym balloons**, each flying out in a different direction. Catch them all!

### ⏱️ Game Types
| Type | Description |
|------|-------------|
| **Survival** | 3 lives – every missed balloon costs a life |
| **Time Attack** | 60-second countdown, no lives lost |
| **Free Play** | No lives, no timer – practice endlessly and finish when you want |

### 🧠 Gameplay Details
- 7 vocabulary topics: Kitchen, Nature, Health, Academic, Travel, Business, Science (you can combine multiple topics in one game)
- Progressive levels – speed and spawn rate increase as you pop more words
- Fast zone / slow zone – balloons rise quickly in the lower part of the screen and slow down near the top
- Overlap-safe spawning so balloons never pile on top of each other
- Golden balloon rain + "LEVEL UP" banner on every new level
- Particle effects, haptic feedback, and live letter-by-letter highlighting as you type
- Live **WPM** and **accuracy** tracking

### 📓 Vocabulary Notebook
- Words from every session (popped, missed, or caught as synonyms) are saved with their meaning, pronunciation, and **example sentence**
- Bookmark words you want to keep, search by word / meaning / example
- Target word is highlighted inside the example sentence
- Text-to-speech for words and example sentences (`flutter_tts`)
- Synonym catches are saved under the **original word** with its full details

### 🔐 Accounts
- Email-based sign up / login powered by Supabase Auth
- Scores and notebook entries are stored per user

---

## 🛠️ Tech Stack

- **Flutter** (Dart)
- **Supabase** – authentication + PostgreSQL database
- **flutter_tts** – pronunciation
- Custom `CustomPainter` balloons, spikes, and topic backgrounds

---

## 📁 Project Structure

```
lib/
├── models/
│   ├── word_tile.dart        # Balloon (tile) model, incl. mother/synonym burst fields
│   ├── word_note.dart        # Vocabulary notebook entry
│   └── topic.dart            # Topic (name, emoji, colors)
├── painters/
│   ├── balloon_painter.dart  # Balloon + spikes painters
│   └── topic_background.dart # Animated topic backgrounds
├── services/
│   └── supabase_service.dart # Auth, scores, words, notebook
└── screens/
    ├── login_screen.dart
    ├── home_screen.dart
    ├── game_screen.dart      # Core game loop
    ├── result_screen.dart
    └── word_notes_screen.dart
```

---

## 🗄️ Database (Supabase)

### `topics`
```sql
create table public.topics (
  id bigserial not null,
  name text not null,
  emoji text not null,
  bg_color text not null,
  theme_color text not null,
  constraint topics_pkey primary key (id)
);
```

### `words`
```sql
create table public.words (
  id bigserial not null,
  word text not null,
  meaning text not null,
  pronunciation text null,
  example_sentence text null,
  synonyms text[] null default '{}'::text[],
  topic_id bigint null,
  difficulty text null default 'easy'::text,
  constraint words_pkey primary key (id),
  constraint words_topic_id_fkey foreign key (topic_id) references topics (id),
  constraint words_difficulty_check check (
    difficulty = any (array['easy'::text, 'advanced'::text])
  )
);
```

Each word has up to 3 synonyms (used by Synonym Pop mode) and a difficulty of `easy` or `advanced`.

### `word_notes`
Stores each user's notebook. The app reads/writes these columns:

`id`, `user_id`, `word`, `meaning`, `pronunciation`, `example_sentence`, `topic_id`, `mode`, `status` (`popped` / `missed` / `synonym`), `learned`, `saved`, `created_at`

> If you added `example_sentence` later, run:
> ```sql
> alter table public.word_notes
>   add column if not exists example_sentence text default '';
> ```

You will also need a table for game scores (used by `SupabaseService.saveScore`) – score, accuracy and WPM per user.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- A [Supabase](https://supabase.com) project

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/<your-username>/Wordninja2.git
   cd Wordninja2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   Add your project URL and anon key where Supabase is initialized (see `lib/services/supabase_service.dart` / `main.dart`).

4. **Create the tables** from the SQL above and insert your topics and words.

5. **Run the app**
   ```bash
   flutter run
   ```

### Setting a custom app icon
Place the generated `mipmap-*` folders (e.g. from [appicon.co](https://appicon.co)) in `android/app/src/main/res/`, rebuild, and **uninstall the old app first** – Android caches launcher icons.

---

## 🗺️ Roadmap

- [ ] Per-account result history (WPM, accuracy, time)
- [ ] Accuracy-over-time progress graph
- [ ] WPM-based badges (Bronze → Platinum)
- [ ] More topics and words

---

## 🤝 Contributing

Issues and pull requests are welcome. For big changes, please open an issue first to discuss what you'd like to change.

---

## 📄 License

Add a license of your choice (e.g. MIT) and update this section.
