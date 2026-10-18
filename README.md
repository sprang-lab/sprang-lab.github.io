# Sprang Lab website

This repository holds the website of the Sprang Lab (BioAI group) at UMC & IQCB, Johannes Gutenberg
University Mainz. It is written in [Quarto](https://quarto.org): every page is a `.qmd` file (Markdown
with a small YAML header), and Quarto turns them into the static site.

This README is for lab members who want to update their profile, write a blog post, or otherwise
change the site.

## Repository structure

```
.
├── _quarto.yml              Site configuration: navbar, footer, theme, which files are built
├── styles.css               All custom styling (colours, cards, slideshow, people pages)
├── index.qmd                Home page, incl. the photo slideshow (raw HTML block)
├── references.bib           BibTeX for the publications page
├── README.md                This file
│
├── people/
│   ├── index.qmd            Team page: one card per person (Team, External Students)
│   ├── alumni.qmd           Former members
│   └── <surname>.qmd        Individual profile pages (sprang, hassan, damico, sevilmis, kammeyer, …)
│
├── research/
│   ├── index.qmd            Research overview (under construction)
│   ├── publications.qmd     Full publication list
│   └── projects.qmd         Projects (under construction)
│
├── blog/
│   ├── index.qmd            Blog listing, generated automatically from posts/
│   └── posts/
│       └── YYYY-MM-DD-title/
│           └── index.qmd    One folder per post; images for the post go in the same folder
│
├── images/
│   ├── profiles/            Profile photos, named name_surname.jpg
│   │   └── thumbs/          Square headshots used on the cards (generated, see below)
│   ├── slideshow/           Home-page slideshow photos, numbered 01-…, 02-…
│   └── placeholder-avatar.svg   Shown until someone sends a photo
│
├── scripts/
│   └── make-headshot.ps1    Crops a square, face-centred headshot from a profile photo
│
├── resources/               Parked, not built (see "Parked: Resources section")
│
├── _site/                   Build output (generated, not committed)
└── .quarto/                 Quarto cache (generated, not committed)
```

## Getting started

1. Install [Quarto](https://quarto.org/docs/get-started/) (version 1.9 or newer).
2. Clone the repository:

   ```bash
   git clone git@github.com:Muedi/sprang-and-friends.git
   cd sprang-and-friends
   ```

3. Start a live preview. It opens the site in your browser and reloads whenever you save a file:

   ```bash
   quarto preview
   ```

## How to contribute

1. Create a branch for your change, e.g. `git switch -c profile-jane-doe` or `git switch -c post-our-new-paper`.
   If you don't have write access to the repository, fork it on GitHub first and work in your fork.
2. Make your edits and check them in `quarto preview`.
3. Commit and push your branch, then open a pull request against `main`.
4. Max reviews and merges it.

If you are not comfortable with git, send your text and photo to Max by email instead.

## Adding or updating your profile

**1. Photo.** Save a reasonably recent photo as `images/profiles/name_surname.jpg` (lower case,
underscores, e.g. `jane_doe.jpg`). JPG or PNG; phone HEIC files do not display in most browsers.

**2. Headshot for the card.** The cards show a round crop, so they need a square image centred on
your face, saved as `images/profiles/thumbs/name_surname.jpg`.

- On Windows, the script does this for you. `CenterX` / `CenterY` give the position of your face as a
  fraction of the photo's width / height, and `Zoom` makes the crop tighter (1 = largest possible square):

  ```bash
  powershell -File scripts/make-headshot.ps1 images/profiles/jane_doe.jpg -CenterX 0.5 -CenterY 0.3 -Zoom 1.5
  ```

- Otherwise, crop the photo to a square of about 400 × 400 px in any image editor and save it there.

**3. Card on the Team page.** Copy an existing card in `people/index.qmd` into the right section
(Team or External Students). Team is ordered by role: PI, PhD students, MD candidates, Master's students.

```markdown
::: {.g-col-12 .g-col-sm-6 .g-col-md-4 .g-col-lg-3}
::: {.person-card}
![](../images/profiles/thumbs/jane_doe.jpg){.profile-photo fig-alt="Jane Doe"}

### Jane Doe

M.Sc. student

*One line about your project*

[Profile &rarr;](doe.qmd)
:::
:::
```

Use `fig-alt="…"` for the alt text, not `![Jane Doe](…)`: text in the square brackets would show up
as a caption under the photo.

**4. Profile page (optional).** Add `people/<surname>.qmd`. Copying `people/kammeyer.qmd` is the easiest
start: photo on the left, "About" and "Project" on the right. If you have papers with the lab, add them
at the end of the right-hand column:

```markdown
::: {.joint-papers}
**Papers with the lab**

- **J Doe**, A Other, **M Sprang**. **Title of the paper.** *Journal*, 2026. [DOI: 10.xxxx/yyyy](https://doi.org/10.xxxx/yyyy)
:::
```

Put the names of all lab members (current and former) in bold.

**Leaving the lab?** Move your entry from `people/index.qmd` to `people/alumni.qmd` and add a
`**Now:** …` line with your new position (see the existing entries there).

## Writing a blog post

Posts by everyone in the lab are welcome, for example about a new paper or a finished thesis, on
your own or together with Max.

1. Create a folder `blog/posts/YYYY-MM-DD-short-title/` and an `index.qmd` inside it.
2. Start the file with this header:

   ```yaml
   ---
   title: "Our new paper on …"
   author: ["Jane Doe", "Maximilian Sprang"]
   date: "2026-11-01"
   categories: [paper]
   description: "One sentence shown in the blog listing."
   ---
   ```

3. Write the post in Markdown below the header. Put any images in the same folder and include them with
   `![Caption](figure.png)`.

The post shows up in the blog listing automatically, newest first.

## Other pages

- **Slideshow** (`index.qmd`): each slide is a `<div class="carousel-item">` block with an image,
  `alt` text, a title (`<h5>`) and a subtitle (`<p>`). This part is raw HTML, so Markdown does not work
  there (write `&amp;` for &). When adding or removing a slide, also add or remove its dot button
  (`data-bs-slide-to`, counted from 0) a few lines above. Photos go in `images/slideshow/`.
- **Publications** (`research/publications.qmd`): a hand-written, continuously numbered list. Follow the
  existing format (author initials, **M Sprang** in bold, DOI link, role badge) and renumber after
  inserting. Add a matching entry to `references.bib`.
- **Styling**: all colours and layout tweaks live in `styles.css`; the palette is defined at the top.

## Parked: Resources section

The Resources pages (`resources/datasets.qmd`, `resources/tools.qmd`) are kept in the repository
but are currently **not part of the site**. To bring them back:

1. In `_quarto.yml`, delete the `- "!resources/"` line under `project: render:`.
2. Re-add the navbar menu in `_quarto.yml` under `website: navbar: left:` (after "Blog"):

   ```yaml
         - text: "Resources"
           menu:
             - text: "Datasets"
               href: resources/datasets.qmd
             - text: "Tools"
               href: resources/tools.qmd
   ```

3. Optionally re-add the Resources card at the end of `index.qmd`:

   ```markdown
   ::: {.grid style="margin-top: 1rem; margin-bottom: 2rem;"}

   ::: {.g-col-12}
   ::: {.card-section .accent-violet}
   ### Resources
   Datasets, tools, and software we build and share with the community.

   [Browse resources &rarr;](resources/datasets.qmd)
   :::
   :::

   :::
   ```

   and change the first card grid back to `style="margin-top: 2rem;"`.
