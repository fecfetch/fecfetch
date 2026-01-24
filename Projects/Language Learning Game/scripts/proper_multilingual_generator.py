#!/usr/bin/env python3
"""
Proper Multilingual Level Generator
Reads from actual word bank files and generates levels with multilingual hints
"""

import json
import re
import random
import sys
import argparse
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Set, Tuple

class ProperMultilingualLevelGenerator:
    def __init__(self):
        self.random = random.Random(42)  # Fixed seed for reproducible results
        
        # Available languages and their configurations
        self.available_configs = {
            'en': {
                'name': 'English',
                'folder': 'ENGLISH-WB',
                'levels': ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
            },
            'de': {
                'name': 'German',
                'folder': 'GERMAN-WB',
                'levels': ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
            },
            'tr': {
                'name': 'Turkish',
                'folder': 'TURKISH-WB',
                'levels': ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
            },
            'fr': {
                'name': 'French',
                'folder': 'FRENCH-WB',
                'levels': ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
            },
            'es': {
                'name': 'Spanish',
                'folder': 'SPANISH-WB',
                'levels': ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
            },
            'zh': {
                'name': 'Chinese',
                'folder': 'CHINESE-WB',
                'levels': ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
            },
            'hi': {
                'name': 'Hindi',
                'folder': 'HINDI-WB',
                'levels': ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
            }
        }
        
    def read_dart_file_content(self, file_path: str) -> str:
        """Read the content of a Dart file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
            return ""
    
    def extract_word_entries_from_content(self, content: str) -> List[Dict]:
        """Extract word entries from Dart file content using regex"""
        entries = []

        # Be tolerant: word-bank Dart files use several map shapes.
        # Approach: find map-like blocks that contain a 'word' key, then
        # attempt to extract either a 'translations' map, a single 'translation'
        # key, or language-specific keys inside the block.

        # Match a map block containing a word key (non-greedy until the matching brace)
        block_pattern = r"\{[^}]*['\"]word['\"]\s*:\s*['\"]([^'\"]+)['\"][^}]*\}"

        for block in re.finditer(block_pattern, content, re.DOTALL):
            block_text = block.group(0)
            word = block.group(1).strip()

            translations: Dict[str, str] = {}

            # Helper to normalize language keys to the canonical names the game expects
            def _normalize_lang(lang_raw: str) -> str:
                l = lang_raw.strip().lower()
                # common aliases and misspellings
                aliases = {
                    'en': 'english', 'english': 'english',
                    'de': 'german', 'german': 'german',
                    'tr': 'turkish', 'turkish': 'turkish', 'turish': 'turkish', 'turk': 'turkish',
                    'fr': 'french', 'french': 'french',
                    'es': 'spanish', 'spanish': 'spanish',
                    'zh': 'chinese', 'chinese': 'chinese',
                    'hi': 'hindi', 'hindi': 'hindi',
                    'native': 'native'
                }
                return aliases.get(l, l)

            # 1) Look for a 'translations' map: { 'lang': 'text', ... }
            m = re.search(r"['\"]translations['\"]\s*:\s*\{(.*?)\}", block_text, re.DOTALL)
            if m:
                body = m.group(1)
                for t in re.finditer(r"['\"](\w+)['\"]\s*:\s*['\"]([^'\"]+)['\"]", body):
                    lang_raw = t.group(1)
                    translation = t.group(2).strip()
                    lang = _normalize_lang(lang_raw)
                    translations[lang] = translation
            else:
                # 2) Look for a single-key 'translation'
                m2 = re.search(r"['\"]translation['\"]\s*:\s*['\"]([^'\"]+)['\"]", block_text)
                if m2:
                    # Assume single 'translation' is English unless otherwise indicated
                    translations['english'] = m2.group(1).strip()
                else:
                    # 3) Look for explicit language keys in the block (e.g. 'german': '...')
                    for t in re.finditer(r"['\"](turkish|german|spanish|chinese|hindi|french|english|native)['\"]\s*:\s*['\"]([^'\"]+)['\"]", block_text, re.IGNORECASE):
                        lang_raw = t.group(1)
                        translation = t.group(2).strip()
                        lang = _normalize_lang(lang_raw)
                        translations[lang] = translation

            if translations:
                entries.append({
                    'word': word,
                    'translations': translations
                })
        
        return entries
    
    def load_word_bank_for_level(self, language_code: str, cefr_level: str) -> List[Dict]:
        """Load word bank for a specific language and CEFR level"""
        if language_code not in self.available_configs:
            raise ValueError(f"Language {language_code} not supported")
        
        config = self.available_configs[language_code]
        if cefr_level not in config['levels']:
            raise ValueError(f"CEFR level {cefr_level} not available for {config['name']}")
        
        # Construct file path
        file_path = f"lib/data/{config['folder']}/word_bank_{config['name'].lower()}_{cefr_level.lower()}.dart"
        
        if not Path(file_path).exists():
            print(f"Warning: Word bank file not found: {file_path}")
            print("Status: Word bank not yet implemented")
            return []
        
        print(f"Loading word bank: {file_path}")
        content = self.read_dart_file_content(file_path)
        
        if not content:
            print(f"Warning: Could not read content from {file_path}")
            print("Status: Word bank not yet populated")
            return []
        
        entries = self.extract_word_entries_from_content(content)
        
        if not entries:
            print(f"Warning: No entries found in {file_path}")
            print("Status: Word bank format not recognized or empty")
            return []
        
        print(f"Extracted {len(entries)} words from {cefr_level}")
        return entries
    
    def load_combined_word_bank(self, language_code: str, target_cefr_level: str) -> List[Dict]:
        """Load combined word bank including target level and all lower levels"""
        config = self.available_configs[language_code]
        level_hierarchy = config['levels']
        
        # Find the index of target level
        try:
            target_index = level_hierarchy.index(target_cefr_level)
        except ValueError:
            raise ValueError(f"Invalid CEFR level: {target_cefr_level}")
        
        # Load target level and all lower levels
        combined_words = []
        levels_to_load = level_hierarchy[:target_index + 1]  # Include target level and all below
        
        print(f"Loading word banks for levels: {levels_to_load}")
        
        for level in levels_to_load:
            level_words = self.load_word_bank_for_level(language_code, level)
            combined_words.extend(level_words)
        
        print(f"Total combined vocabulary: {len(combined_words)} words")
        return combined_words
    
    def load_all_word_banks_for_language(self, language_code: str) -> List[Dict]:
        """Load all word bank files for a specific language"""
        config = self.available_configs[language_code]
        level_hierarchy = config['levels']
        
        # Load all levels for this language
        combined_words = []
        
        print(f"Loading all word banks for {config['name']}: {level_hierarchy}")
        
        for level in level_hierarchy:
            level_words = self.load_word_bank_for_level(language_code, level)
            combined_words.extend(level_words)
        
        print(f"Total vocabulary from all levels: {len(combined_words)} words")
        return combined_words
    
    def can_form_word(self, word: str, available_letters: List[str]) -> bool:
        """Check if a word can be formed from available letters"""
        # Normalize German 'ß' to 'ss'
        normalized_word = word.upper().replace('ß', 'SS')
        normalized_available = [l.upper().replace('ß', 'SS') for l in available_letters]

        # Flatten the list of available letters if some letters were expanded (e.g., 'ß' -> 'SS')
        flat_available = []
        for l in normalized_available:
            flat_available.extend(list(l))

        word_letters = list(normalized_word)
        available = flat_available.copy()
        
        for letter in word_letters:
            if letter in available:
                available.remove(letter)
            else:
                return False
        return True
    
    def find_formable_words_from_wordbank(self, source_word: str, word_bank: List[Dict], min_length: int = 3) -> List[str]:
        """Find all words from the word bank that can be formed from the source word"""
        # Normalize German 'ß' to 'ss'
        normalized_source = source_word.upper().replace('ß', 'SS')
        source_letters = list(normalized_source)
        
        formable_words = []
        seen_words = set()  # To prevent duplicates
        
        for entry in word_bank:
            word = entry['word']
            normalized_word = word.upper().replace('ß', 'SS')
            
            # Check original word length against normalized source length
            if (normalized_word != normalized_source and
                len(normalized_word) >= min_length and
                len(normalized_word) <= len(normalized_source) and
                self.can_form_word(normalized_word, source_letters) and
                normalized_word not in seen_words):
                formable_words.append(word.upper())  # Return original word in uppercase
                seen_words.add(normalized_word)
        
        return formable_words
    
    def generate_multilingual_hints(self, target_words: List[str], word_bank: List[Dict]) -> Dict[str, str]:
        """Generate hints in all available languages from the word bank"""
        hints = {}
        
        # Get all available languages from word bank
        available_languages = set()
        for entry in word_bank:
            available_languages.update(entry['translations'].keys())
        
        # Generate hints for each language
        for language in available_languages:
            language_hints = []
            
            for target_word in target_words:
                # Find the word in word bank
                translation = target_word.lower()  # fallback
                for entry in word_bank:
                    if entry['word'].upper() == target_word.upper():
                        translation = entry['translations'].get(language, target_word.lower())
                        break
                
                language_hints.append(translation)
            
            hints[language] = " | ".join(language_hints)
        
        return hints
    
    def expand_source_word(self, source_word: str, word_bank: List[Dict], min_targets: int = 3) -> str:
        """Expand source word by adding strategic letters to create more target words"""
        # Common letters that often create new words when added
        expansion_letters = ['s', 'e', 'd', 'r', 'n', 't', 'l', 'i', 'o', 'a', 'u', 'h', 'g', 'f', 'c', 'm', 'p', 'b', 'w', 'y']
        
        # Try the original word first
        original_formable = self.find_formable_words_from_wordbank(source_word, word_bank, min_length=3)
        if len(original_formable) >= min_targets:
            return source_word
        
        # Try adding each expansion letter at different positions
        best_expansion = source_word
        best_score = len(original_formable)
        
        for letter in expansion_letters:
            # Try adding the letter at different positions
            for pos in range(len(source_word) + 1):
                expanded_word = source_word[:pos] + letter + source_word[pos:]
                
                # Don't make words too long
                if len(expanded_word) > 20:
                    continue
                
                formable_words = self.find_formable_words_from_wordbank(expanded_word, word_bank, min_length=3)
                score = len(formable_words)
                
                # Bonus for including the original source word
                if source_word.upper() in [w.upper() for w in formable_words]:
                    score += 2
                
                if score > best_score:
                    best_score = score
                    best_expansion = expanded_word
        
        # If still not enough words, try adding two letters
        if len(self.find_formable_words_from_wordbank(best_expansion, word_bank)) < min_targets:
            for letter1 in expansion_letters[:10]:
                for letter2 in expansion_letters[:5]:
                    if letter1 == letter2:
                        continue
                    
                    # Try different positions for double expansion
                    positions = [
                        source_word + letter1 + letter2,
                        letter1 + source_word + letter2,
                        letter1 + letter2 + source_word,
                    ]
                    
                    for double_expanded in positions:
                        if len(double_expanded) > 10:
                            continue
                        
                        formable_words = self.find_formable_words_from_wordbank(double_expanded, word_bank, min_length=3)
                        if len(formable_words) >= min_targets:
                            return double_expanded
        
        return best_expansion

    def calculate_ruby_reward(self, target_words: List[str]) -> int:
        """Calculate ruby reward based on the sum of target word lengths"""
        if not target_words:
            return 5
        
        total_letter_count = sum(len(word) for word in target_words)
        reward = (total_letter_count / 3) + len(target_words)
        
        # Round up to the nearest integer
        return int(reward + 0.99)

    def generate_levels(self, language_code: str, cefr_level: str, max_levels: int = 90) -> Dict:
        """Generate levels from word bank files with comprehensive word tracking"""
        print(f"Generating levels for {language_code.upper()} {cefr_level}...")
        
        # Load the specific word bank for the current CEFR level for source word selection
        source_word_bank = self.load_word_bank_for_level(language_code, cefr_level)
        
        # Load combined word bank (target level + all lower levels) for target word selection and hints
        target_word_bank = self.load_combined_word_bank(language_code, cefr_level)
        
        # Load all word banks for the target language for valid word checking
        all_word_banks = self.load_all_word_banks_for_language(language_code)
        
        if not source_word_bank:
            print(f"Warning: No source word bank loaded for {language_code} {cefr_level}")
            print("Status: Level generation skipped due to missing word bank")
            return {
                "metadata": {
                    "targetLanguage": language_code,
                    "nativeLanguage": "all",
                    "cefrLevel": cefr_level,
                    "totalLevels": 0,
                    "generatedAt": datetime.now().isoformat(),
                    "description": f"Levels for {cefr_level} proficiency in {language_code.upper()}",
                    "status": "Word bank not yet implemented"
                },
                "levels": []
            }
        
        levels = []
        
        # Comprehensive word tracking system
        used_source_words = set()  # Never reuse source words
        used_target_words = []     # Track recently used target words
        word_usage_count = {}      # Count how often each word has been used
        
        # Avoidance windows
        target_word_avoidance_window = 20  # Don't repeat target words for 20 levels
        max_word_usage = 3  # Maximum times a word can appear as target across all levels
        
        # Sort words by length DESCENDING (longest first) for progressive difficulty
        sorted_words = sorted(source_word_bank, key=lambda x: len(x['word']), reverse=True)
        
        # Start world based on CEFR level index: A1=0, A2=1, B1=2, B2=3, C1=4, C2=5
        try:
            level_index = self.available_configs[language_code]['levels'].index(cefr_level)
        except Exception:
            level_index = 0

        # First, try to process all source words without expansion
        unexpanded_candidates = []
        expanded_candidates = []
        
        # Categorize all source words into those that can generate levels without expansion and those that need expansion
        for entry in sorted_words:
            source_word = entry['word']

            # Skip if already used as source word
            # During initial categorization we allow 2-letter words to ensure they can be considered
            # for the first 18 levels, but we still skip words that are too short (0 or 1 letter)
            min_source_length = 2
            if source_word.upper() in used_source_words or len(source_word) < min_source_length:
                continue
            
            # Skip if this word has been overused as a target word
            if word_usage_count.get(source_word.lower(), 0) >= max_word_usage:
                continue
            
            # Try to find formable words from the original source word
            # For the initial categorization, we still use min_length=3 to be consistent with the original logic
            # The actual generation for first 18 levels will use min_length=2
            formable_words = self.find_formable_words_from_wordbank(source_word, target_word_bank, min_length=3)
            
            # Add the original source word as a target word (important!)
            # Make sure it's not already in the list to avoid duplicates
            if source_word.upper() not in [w.upper() for w in formable_words]:
                formable_words.append(source_word.upper())
            
            # Check if we have enough target words from the original source word
            if len(formable_words) >= 3:  # We need at least 3 targets
                unexpanded_candidates.append((entry, formable_words))
            else:
                # This word needs expansion
                expanded_candidates.append((entry, formable_words))
        
        # Process candidates in the right order: first unexpanded, then expanded
        all_candidates = unexpanded_candidates + expanded_candidates

        # Debug: candidate stats
        print(f"Debug: unexpanded_candidates={len(unexpanded_candidates)}, expanded_candidates={len(expanded_candidates)}, total_candidates={len(all_candidates)}")
        # Print a small sample of candidate words for inspection
        try:
            sample_candidates = [entry['word'] for entry, _ in all_candidates[:10]]
            print(f"Debug sample candidates (up to 10): {sample_candidates}")
        except Exception:
            pass

        # For debugging, track why candidates get filtered out for the first N items
        debug_candidate_limit = 20
        debug_count = 0

        # Use a rotating queue so that candidates skipped early (e.g. because
        # they're too long for the "first three levels") get deferred and
        # reconsidered later instead of being permanently skipped.
        from collections import deque
        candidates = deque(all_candidates)

        # First, generate the first 3 levels (world 0, subworld 0, levels 0, 1, 2) if target language is English
        if language_code == 'en':
            print("Generating first 3 levels...")
            # Generate first 3 levels with special handling
            # We'll use the same logic as the regular levels, but with forced source words
            first_3_forced_words = ["word", "woman", "come"]
            
            # Process the forced words in order
            for level_in_subworld, forced_word in enumerate(first_3_forced_words):
                if len(levels) >= max_levels:
                    break
                    
                # Find the candidate for this forced word
                forced_candidate = None
                for entry, formable_words in all_candidates:
                    if entry['word'].lower() == forced_word:
                        forced_candidate = (entry, formable_words)
                        break
                
                # If we found the candidate, process it
                if forced_candidate:
                    entry, formable_words = forced_candidate
                    source_word = entry['word']
                    
                    # This is a forced word, process it with the regular logic
                    # Special handling for first 18 levels of World 0 (subworld 0)
                    is_first_eighteen_levels = True  # First 3 levels are part of first 18 levels
                    
                    # Skip if already used as source word
                    # For first 18 levels of world 0, allow 2-letter words; for others, require at least 4 letters
                    min_source_length = 2 if is_first_eighteen_levels else 4
                    if source_word.upper() in used_source_words or len(source_word) < min_source_length:
                        # For forced words, we'll try to process them even if they don't meet the normal criteria
                        # But we still need to check the basic criteria
                        if source_word.upper() in used_source_words or len(source_word) < 2:
                            print(f"Warning: Forced word {source_word} cannot be used as source word")
                            continue
                    
                    # Skip if this word has been overused as a target word
                    if word_usage_count.get(source_word.lower(), 0) >= max_word_usage:
                        print(f"Warning: Forced word {source_word} has been overused as target word")
                        # For forced words, we'll allow them even if they've been overused
                    
                    # For the first 3 levels, do not expand the source words
                    # Use the original source word as is
                    expanded_source_word = source_word
                    
                    # Find words from word bank that can be formed from the source word
                    # Use the combined word bank for target word selection
                    # For first 18 levels, allow 2-letter words as targets; for others, require at least 3 letters
                    min_length = 2 if is_first_eighteen_levels else 3
                    formable_words = self.find_formable_words_from_wordbank(source_word, target_word_bank, min_length=min_length)
                    
                    # Add the original source word as a target word (important!)
                    # Make sure it's not already in the list to avoid duplicates
                    if source_word.upper() not in [w.upper() for w in formable_words]:
                        formable_words.append(source_word.upper())
                    
                    # Advanced filtering for target word selection
                    available_targets = []
                    # Debugging counters for why candidate words are excluded
                    filtered_recent = 0
                    filtered_overused = 0
                    filtered_used_as_source = 0
                    for word in formable_words:
                        word_lower = word.lower()
                        
                        # Skip if word was used recently as target
                        if word_lower in used_target_words[-target_word_avoidance_window:]:
                            filtered_recent += 1
                            continue
                        
                        # Skip if word has been overused
                        # For forced words, we'll be more lenient with overused words
                        if word_usage_count.get(word_lower, 0) >= max_word_usage:
                            filtered_overused += 1
                            continue
                        
                        # Skip if word was already used as source (to maintain variety)
                        # But allow the source word itself to be a target
                        if word.upper() in used_source_words and word.upper() != source_word.upper():
                            filtered_used_as_source += 1
                            continue
                        
                        available_targets.append(word)

                    # If in debug window, print why this candidate failed/what passed
                    if debug_count < debug_candidate_limit:
                        print(f"Candidate '{entry['word']}' -> formable={len(formable_words)}, available_targets={len(available_targets)}, filtered_recent={filtered_recent}, filtered_overused={filtered_overused}, filtered_used_as_source={filtered_used_as_source}")
                        if len(available_targets) > 0:
                            print(f"  sample available: {available_targets[:6]}")
                        debug_count += 1
                    
                    # If we filtered out too many words, relax some constraints
                    # For forced words, we'll be more lenient
                    if len(available_targets) < 2:
                        # First fallback: allow recently used targets but not overused ones
                        available_targets = [w for w in formable_words
                                           if word_usage_count.get(w.lower(), 0) < max_word_usage
                                           and (w.upper() not in used_source_words or w.upper() == source_word.upper())]
                        
                        # Second fallback: allow some overused words but prioritize less used ones
                        if len(available_targets) < 2:
                            available_targets = [w for w in formable_words
                                               if (w.upper() not in used_source_words or w.upper() == source_word.upper())]
                            # Sort by usage count (least used first)
                            available_targets.sort(key=lambda w: word_usage_count.get(w.lower(), 0))
                    
                    if len(available_targets) >= 2:  # Need at least 2 formable words
                        # Prefer 3+ target words, but accept 2 if necessary
                        # For first 18 levels, we can have fewer targets
                        min_targets = 2 if is_first_eighteen_levels else (3 if len(available_targets) >= 3 else 2)
                        
                        # Sort target words by length DESCENDING (longer words first) for better gameplay
                        # Then by usage count (less used words first) for variety
                        sorted_targets = sorted(available_targets,
                                              key=lambda w: (-len(w), word_usage_count.get(w.lower(), 0)))
                        
                        # Select target words prioritizing longer, less-used ones
                        # For first 18 levels, limit to max 4 words; for others, up to 8 words
                        max_selected_targets = 4 if is_first_eighteen_levels else 8
                        selected_targets = sorted_targets[:max_selected_targets]
                        
                        # Take the best targets
                        # For first 18 levels, limit to max 4 target words; for others, max 6
                        max_final_targets = 4 if is_first_eighteen_levels else 6
                        final_targets = selected_targets[:min(max_final_targets, len(selected_targets))]
                        
                        # Ensure we have at least min_targets
                        if len(final_targets) < min_targets and len(sorted_targets) >= min_targets:
                            final_targets = sorted_targets[:min_targets]
                        
                        # Add the source word to used_source_words to prevent it from being used again
                        # Only do this after we've selected the final targets
                        used_source_words.add(source_word.upper())
                        
                        # Track target word usage for the source word itself
                        word_usage_count[source_word.lower()] = word_usage_count.get(source_word.lower(), 0) + 1
                        used_target_words.append(source_word.lower())
                        
                        # Generate multilingual hints from word bank
                        multilingual_hints = self.generate_multilingual_hints(final_targets, target_word_bank)
                        
                        # Valid words include all formable words (not just targets)
                        # Use all word banks for valid word checking (new requirement)
                        # For first 18 levels, allow 2-letter words as valid words; for others, require at least 3 letters
                        min_length = 2 if is_first_eighteen_levels else 3
                        all_formable = self.find_formable_words_from_wordbank(source_word, all_word_banks, min_length=min_length)
                        if source_word.upper() not in [w.upper() for w in all_formable]:
                            all_formable.append(source_word.upper())
                        
                        valid_words = sorted([word.lower() for word in all_formable])
                        
                        # Create level
                        level = {
                            "world": 0,
                            "subWorld": 0,
                            "level": level_in_subworld,
                            "sourceWord": source_word.lower().replace('ß', 'ss'),
                            "targetWords": final_targets,
                            "hints": multilingual_hints,
                            "validWords": valid_words,
                            "rubyReward": self.calculate_ruby_reward(final_targets)
                        }
                        
                        levels.append(level)
                        
                        if len(levels) % 10 == 0:
                            print(f"Generated {len(levels)} levels...")
                            print(f"  Word usage stats: {len(word_usage_count)} unique words used")
                            print(f"  Most used words: {sorted(word_usage_count.items(), key=lambda x: x[1], reverse=True)[:5]}")
        
        print(f"Generated first 3 levels, now generating remaining levels...")
        
        # Now generate the remaining levels
        world = level_index
        sub_world = 4
        level_in_subworld = 17
        attempts = 0
        max_attempts = 1000000000000000000  # Prevent infinite loops
        
        # Flag to track if we've passed the first 3 levels
        passed_first_three = False

        while candidates and len(levels) < max_levels and attempts < max_attempts:
            entry, formable_words = candidates.popleft()

            attempts += 1
            source_word = entry['word']
            
            # Skip if we're at the first 3 levels and target language is English
            # These levels have already been generated
            if language_code == 'en' and world == 0 and sub_world == 0 and level_in_subworld in [0, 1, 2]:
                # Skip these levels as they've already been generated
                # Update world/subworld structure
                level_in_subworld -= 1
                if level_in_subworld < 0:  # 18 levels per subworld
                    level_in_subworld = 17
                    sub_world -= 1
                    if sub_world < 0:  # 5 subworlds per world
                        sub_world = 4
                        world += 1
                continue

            # Special handling for first 18 levels of World 0 (subworld 0)
            is_first_eighteen_levels = (world == 0 and sub_world == 0 and level_in_subworld >= 0)  # First 18 levels (0-17)

            # Skip if already used as source word
            # For first 18 levels of world 0, allow 2-letter words; for others, require at least 4 letters
            min_source_length = 2 if is_first_eighteen_levels else 4
            if source_word.upper() in used_source_words or len(source_word) < min_source_length:
                continue

            # For first 18 levels, defer words longer than 4 letters instead of dropping them
            if is_first_eighteen_levels and len(source_word) > 4:
                # Put it at the end of the queue to try again later
                candidates.append((entry, formable_words))
                continue
            
            # Skip if this word has been overused as a target word
            if word_usage_count.get(source_word.lower(), 0) >= max_word_usage:
                continue
            
            # Determine if this is an unexpanded or expanded candidate
            is_unexpanded_candidate = any(entry['word'] == source_word for entry, _ in unexpanded_candidates)
            
            if is_unexpanded_candidate:
                # Use the original source word
                expanded_source_word = source_word
            else:
                # Expand source word if needed to get enough target words
                expanded_source_word = self.expand_source_word(source_word, target_word_bank, min_targets=3)
                
                # Find words from word bank that can be formed from the expanded source word
                # Use the combined word bank for target word selection
                # For first 18 levels, allow 2-letter words as targets; for others, require at least 3 letters
                min_length = 2 if is_first_eighteen_levels else 3
                formable_words = self.find_formable_words_from_wordbank(expanded_source_word, target_word_bank, min_length=min_length)
                
                # Add the original source word as a target word (important!)
                # Make sure it's not already in the list to avoid duplicates
                if source_word.upper() not in [w.upper() for w in formable_words]:
                    formable_words.append(source_word.upper())
            
            # Advanced filtering for target word selection
            available_targets = []
            # Debugging counters for why candidate words are excluded
            filtered_recent = 0
            filtered_overused = 0
            filtered_used_as_source = 0
            for word in formable_words:
                word_lower = word.lower()
                
                # Skip if word was used recently as target
                if word_lower in used_target_words[-target_word_avoidance_window:]:
                    filtered_recent += 1
                    continue
                
                # Skip if word has been overused
                if word_usage_count.get(word_lower, 0) >= max_word_usage:
                    filtered_overused += 1
                    continue
                
                # Skip if word was already used as source (to maintain variety)
                if word.upper() in used_source_words:
                    filtered_used_as_source += 1
                    continue
                
                available_targets.append(word)

            # If in debug window, print why this candidate failed/what passed
            if debug_count < debug_candidate_limit:
                print(f"Candidate '{entry['word']}' -> formable={len(formable_words)}, available_targets={len(available_targets)}, filtered_recent={filtered_recent}, filtered_overused={filtered_overused}, filtered_used_as_source={filtered_used_as_source}")
                if len(available_targets) > 0:
                    print(f"  sample available: {available_targets[:6]}")
                debug_count += 1
            
            # If we filtered out too many words, relax some constraints
            if len(available_targets) < 2:
                # First fallback: allow recently used targets but not overused ones
                available_targets = [w for w in formable_words
                                   if word_usage_count.get(w.lower(), 0) < max_word_usage
                                   and w.upper() not in used_source_words]
                
                # Second fallback: allow some overused words but prioritize less used ones
                if len(available_targets) < 2:
                    available_targets = [w for w in formable_words
                                       if w.upper() not in used_source_words]
                    # Sort by usage count (least used first)
                    available_targets.sort(key=lambda w: word_usage_count.get(w.lower(), 0))
            
            if len(available_targets) >= 2:  # Need at least 2 formable words
                # Special handling for first 18 levels of World 0
                is_first_eighteen_levels = (world == 0 and sub_world == 0 and level_in_subworld >= 0)  # First 18 levels (0-17)
                
                # Prefer 3+ target words, but accept 2 if necessary
                # For first 18 levels, we can have fewer targets
                min_targets = 2 if is_first_eighteen_levels else (3 if len(available_targets) >= 3 else 2)
                
                # Sort target words by length DESCENDING (longer words first) for better gameplay
                # Then by usage count (less used words first) for variety
                sorted_targets = sorted(available_targets,
                                      key=lambda w: (-len(w), word_usage_count.get(w.lower(), 0)))
                
                # Select target words prioritizing longer, less-used ones
                # For first 18 levels, limit to max 4 words; for others, up to 8 words
                max_selected_targets = 4 if is_first_eighteen_levels else 8
                selected_targets = sorted_targets[:max_selected_targets]
                
                # Take the best targets
                # For first 18 levels, limit to max 4 target words; for others, max 6
                max_final_targets = 4 if is_first_eighteen_levels else 6
                final_targets = selected_targets[:min(max_final_targets, len(selected_targets))]
                
                # Ensure we have at least min_targets
                if len(final_targets) < min_targets and len(sorted_targets) >= min_targets:
                    final_targets = sorted_targets[:min_targets]
                
                # Generate multilingual hints from word bank
                multilingual_hints = self.generate_multilingual_hints(final_targets, target_word_bank)
                
                # Valid words include all formable words (not just targets)
                # Use all word banks for valid word checking (new requirement)
                # For first 18 levels, allow 2-letter words as valid words; for others, require at least 3 letters
                min_length = 2 if is_first_eighteen_levels else 3
                all_formable = self.find_formable_words_from_wordbank(expanded_source_word, all_word_banks, min_length=min_length)
                if source_word.upper() not in [w.upper() for w in all_formable]:
                    all_formable.append(source_word.upper())
                
                valid_words = sorted([word.lower() for word in all_formable])
                
                # Create level
                level = {
                    "world": world,
                    "subWorld": sub_world,
                    "level": level_in_subworld,
                    "sourceWord": expanded_source_word.lower().replace('ß', 'ss'),
                    "targetWords": final_targets,
                    "hints": multilingual_hints,
                    "validWords": valid_words,
                    "rubyReward": self.calculate_ruby_reward(final_targets)
                }
                
                levels.append(level)
                
                # Update tracking systems
                used_source_words.add(source_word.upper())
                used_source_words.add(expanded_source_word.upper())
                
                # Track target word usage
                for target in final_targets:
                    target_lower = target.lower()
                    used_target_words.append(target_lower)
                    word_usage_count[target_lower] = word_usage_count.get(target_lower, 0) + 1
                
                # Update world/subworld structure
                level_in_subworld -= 1
                if level_in_subworld < 0:  # 18 levels per subworld
                    level_in_subworld = 17
                    sub_world -= 1
                    if sub_world < 0:  # 5 subworlds per world
                        sub_world = 4
                        world += 1
                
                if len(levels) % 10 == 0:
                    print(f"Generated {len(levels)} levels...")
                    print(f"  Word usage stats: {len(word_usage_count)} unique words used")
                    print(f"  Most used words: {sorted(word_usage_count.items(), key=lambda x: x[1], reverse=True)[:5]}")
        # Create final structure
        result = {
            "metadata": {
                "targetLanguage": language_code,
                "nativeLanguage": "all",
                "cefrLevel": cefr_level,
                "totalLevels": len(levels),
                "generatedAt": datetime.now().isoformat(),
                "description": f"Levels for {cefr_level} proficiency in {language_code.upper()}"
            },
            "levels": levels
        }

        print(f"Generated {len(levels)} levels for {language_code.upper()} {cefr_level}")
        print(f"Final word usage stats:")
        print(f"  Total unique words used: {len(word_usage_count)}")
        if len(word_usage_count) > 0:
            print(f"  Average usage per word: {sum(word_usage_count.values()) / len(word_usage_count):.2f}")
        else:
            print(f"  Average usage per word: 0.00")

        return result
    
    def save_levels(self, levels_data: Dict, target_language_code: str, cefr_level: str):
        """Save levels to JSON file"""
        output_path = f"assets/levels/{target_language_code}_{cefr_level.lower()}_levels.json"
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(levels_data, f, indent=2, ensure_ascii=False)
        
        print(f"Saved levels to {output_path}")
    
    def list_available_combinations(self):
        """List all available language/level combinations"""
        print("Available language/level combinations:")
        for lang_code, config in self.available_configs.items():
            print(f"  {lang_code} ({config['name']}): {', '.join(config['levels'])}")

def main():
    parser = argparse.ArgumentParser(description='Generate multilingual game levels from word banks')
    parser.add_argument('--target-language', '-t', required=True, help='Target language code (en, de, tr, fr, es, zh, hi)')
    parser.add_argument('--level', '-c', required=True, help='CEFR level (A1, A2, B1, B2, C1, C2)')
    parser.add_argument('--max-levels', '-m', type=int, default=90, help='Maximum number of levels to generate')
    parser.add_argument('--list', action='store_true', help='List available combinations')
    
    args = parser.parse_args()
    
    generator = ProperMultilingualLevelGenerator()
    
    if args.list:
        generator.list_available_combinations()
        return
    
    try:
        levels_data = generator.generate_levels(args.target_language, args.level, args.max_levels)
        generator.save_levels(levels_data, args.target_language, args.level)
        print(f"Successfully generated {args.target_language.upper()} {args.level} levels!")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()