# A bracket is considered to be any one of the following characters: (, ), {, }, [, or ].

# Two brackets are considered to be a matched pair if the an opening bracket (i.e., (, [, or {) occurs to the left of a closing bracket (i.e., ), ], or }) of the exact same type. There are three types of matched pairs of brackets: [], {}, and ().

# A matching pair of brackets is not balanced if the set of brackets it encloses are not matched. For example, {[(])} is not balanced because the contents in between { and } are not balanced. The pair of square brackets encloses a single, unbalanced opening bracket, (, and the pair of parentheses encloses a single, unbalanced closing square bracket, ].

# By this logic, we say a sequence of brackets is considered to be balanced if the following conditions are met:

# It contains no unmatched brackets.
# The subset of brackets enclosed within the confines of a matched pair of brackets is also a matched pair of brackets.

# Given a string of brackets, determine whether it is balanced. Return true or false.

def balanced_brackets?(input_str)
  brackets = {
    '(' => ')',
    '{' => '}',
    '[' => ']',
    ')' => '(',
    '}' => '{',
    ']' => '['
  }

  allowed_brackets = brackets.keys
  opening_brackets = allowed_brackets[0..2]
  closing_brackets = allowed_brackets[3..5]
  queue = []

  input_str.split('').each do |char|
    next unless allowed_brackets.include?(char)

    if opening_brackets.include?(char)
      queue.push(char)
    else
      opening_bracket = queue.pop
      return false if brackets[char] != opening_bracket
    end
  end

  queue.empty?
end