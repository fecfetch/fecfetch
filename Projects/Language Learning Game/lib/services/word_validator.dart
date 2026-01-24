class WordValidator {
  /// Checks if a target word can be formed from the source word letters
  static bool canFormWord(String sourceWord, String targetWord) {
    final sourceLetters = sourceWord.toLowerCase().split('');
    final targetLetters = targetWord.toLowerCase().split('');

    // Count frequency of each letter in source word
    final sourceCount = <String, int>{};
    for (String letter in sourceLetters) {
      sourceCount[letter] = (sourceCount[letter] ?? 0) + 1;
    }

    // Check if target word can be formed
    final targetCount = <String, int>{};
    for (String letter in targetLetters) {
      targetCount[letter] = (targetCount[letter] ?? 0) + 1;
    }

    // Verify each letter in target exists in sufficient quantity in source
    for (String letter in targetCount.keys) {
      if ((sourceCount[letter] ?? 0) < targetCount[letter]!) {
        return false;
      }
    }

    return true;
  }

  /// Finds all possible words that can be formed from source letters
  static List<String> findPossibleWords(
      String sourceWord, List<String> wordBank) {
    return wordBank
        .where((word) => word.length >= 2 && canFormWord(sourceWord, word))
        .toList();
  }

  /// Validates a complete level to ensure all target words are possible
  static bool validateLevel(String sourceWord, List<String> targetWords) {
    return targetWords.every((word) => canFormWord(sourceWord, word));
  }
}
