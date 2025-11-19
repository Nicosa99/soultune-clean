# Claude Code Prompt: Fix Discovery Page Study Links

## Task: Update incorrect study links in Discovery Screen

The Discovery screen (`discovery_screen.dart`) currently has **3 incorrect study links** that need to be fixed. All links are in the `_buildResearchSection` method.

---

## Changes Required

### 1. Fix PLOS ONE 2024 Study Link

**Location:** `_buildResearchSection()` method, "PLOS ONE 2024 - Panning Binaural Beats" button

**Current (WRONG):**
```dart
_buildLinkButton(
  context,
  'PLOS ONE 2024 - Panning Binaural Beats',
  'https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0306229',
  Icons.article,
  theme,
),
```

**Change to (CORRECT):**
```dart
_buildLinkButton(
  context,
  'PLOS ONE 2024 - Panning Binaural Beats',
  'https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0306427',
  Icons.article,
  theme,
),
```

**Reason:** Wrong DOI - correct article is `pone.0306427` (Sudre et al., July 30, 2024)

---

### 2. Fix Nature 2024 Study Link

**Location:** `_buildResearchSection()` method, "Nature 2024 - Cognitive Enhancement Study" button

**Current (WRONG):**
```dart
_buildLinkButton(
  context,
  'Nature 2024 - Cognitive Enhancement Study',
  'https://www.nature.com/articles/s41598-024-52556-0',
  Icons.article,
  theme,
),
```

**Change to (CORRECT):**
```dart
_buildLinkButton(
  context,
  'Nature 2024 - Cognitive Enhancement Study',
  'https://www.nature.com/articles/s41598-024-68628-9',
  Icons.article,
  theme,
),
```

**Reason:** Wrong article ID - correct is `s41598-024-68628-9` (Chockboondee et al., August 4, 2024)

---

### 3. Fix OBE 2014 Study Link

**Location:** `_buildResearchSection()` method, "Frontiers 2014 - OBE Brain Mapping" button

**Current (WRONG):**
```dart
_buildLinkButton(
  context,
  'Frontiers 2014 - OBE Brain Mapping',
  'https://www.frontiersin.org/articles/10.3389/fnhum.2014.00070/full',
  Icons.article,
  theme,
),
```

**Change to (CORRECT):**
```dart
_buildLinkButton(
  context,
  'Frontiers 2014 - OBE Brain Mapping',
  'https://pubmed.ncbi.nlm.nih.gov/24550805/',
  Icons.article,
  theme,
),
```

**Reason:** Use PubMed link for Smith & Messier 2014 study (University of Ottawa fMRI OBE research)

---

## Implementation Steps

1. Open `lib/features/discovery/presentation/screens/discovery_screen.dart`
2. Navigate to `_buildResearchSection()` method
3. Find the three link buttons mentioned above
4. Update the URL string in each `_buildLinkButton` call
5. Save the file
6. Test: Click each link to verify they open correctly

---

## Verification

After making changes, verify each link opens the correct study:

- **PLOS ONE 2024:** Should open Sudre et al. article about panning binaural beats
- **Nature 2024:** Should open Chockboondee et al. article about 6 Hz daily listening
- **OBE 2014:** Should open PubMed entry for Smith & Messier fMRI study

---

## Optional Improvements

### Add 432 Hz Study Links

If you want to add the 432 Hz studies referenced in the Discovery page text, add these buttons in `_buildResearchSection()`:

```dart
// After "PEER-REVIEWED STUDIES" section, add new subsection:

const SizedBox(height: 20),
Text(
  '432 HZ RESEARCH',
  style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
    color: colorScheme.primary,
  ),
),
const SizedBox(height: 12),

_buildLinkButton(
  context,
  'Italian Study 2019 - Heart Rate Effects',
  'https://pubmed.ncbi.nlm.nih.gov/31031095/',
  Icons.favorite,
  theme,
),
const SizedBox(height: 8),
Text(
  'Calamassi & Pomponi: 432 Hz music decreased heart rate '\
  'by 4.79 bpm (p=0.05) compared to 440 Hz',
  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
),

const SizedBox(height: 16),

_buildLinkButton(
  context,
  'Chilean Dental Study 2020 - Cortisol',
  'https://www.scielo.br/j/jaos/a/kkzqnX5PgqgdKzT3BhHdX7w/',
  Icons.spa,
  theme,
),
const SizedBox(height: 8),
Text(
  'Aravena et al.: 432 Hz reduced salivary cortisol by 64% '\
  'vs. 440 Hz (p<0.05) - biological stress marker validation',
  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
),
```

---

## Quick Summary

**3 links to fix:**
1. PLOS ONE: `...pone.0306229` → `...pone.0306427`
2. Nature: `...s41598-024-52556-0` → `...s41598-024-68628-9`
3. OBE Study: Frontiers link → PubMed link `24550805`

All changes are in `_buildResearchSection()` method.