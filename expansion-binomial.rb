def expand(binomial_string = '')
  return 'Error' if parse(binomial_string).empty?
  parsed_binomial = parse binomial_string
  expanded_binomial =  newton_binomial parsed_binomial
  stringify_expression expanded_binomial
end

def parse(equation_string)
  equation_string_parts = equation_string.split(/[\^\ˆ]/)
  binomial = equation_string_parts.first.gsub(/[\(\)]/, '')
  components = []
  binomial.scan(/[-+]?[0-9]?[a-zA-Z]?/).select{ |v| !v.empty? }.each do |string_term|
    components << build_term(string_term)
  end
  {
    components: components,
    exponent: equation_string_parts[1] ? equation_string_parts.last.to_i : 1
  }
end

def build_term(string_term)
  term = { coefficient: '', variable: nil, exponent: 1 }
  string_term.split('').each do |character|
    case character
      when /[0-9]/
        term[:coefficient] << character
      when /[a-zA-Z]/
        term[:variable] = character
      when /[+-]/
        term[:coefficient] << character
      end
    end
  if term[:coefficient].empty?
    term[:coefficient] = 1
  elsif term[:coefficient] == '-'
    term[:coefficient] = -1
  else
    term[:coefficient] = term[:coefficient].to_i
  end
  term
end

def get_coefficient(n, k)
  [*1..n].combination(k).count
end

def newton_binomial(binomial)
  return [{coefficient: 1, variable: nil, exponent: 1}] if binomial[:exponent] == 0
  final_expression = []
  n = binomial[:exponent]
  (n+1).times do |k|
    coefficient = get_coefficient(n, k)
    a = {
      coefficient: binomial[:components].first[:coefficient] ** (n - k),
      variable: binomial[:components].first[:variable],
      exponent: n - k
    }
    b = {
      coefficient: binomial[:components].last[:coefficient] ** k,
      variable: nil,
      exponent: 1
    }
    final_expression << {
      coefficient: a[:coefficient] * b[:coefficient] * coefficient,
      variable: a[:exponent] >=1 ? a[:variable] : nil,
      exponent: a[:exponent]
    }
  end
  final_expression
end

def stringify_expression(components)
  components.inject('') do |result_string, component|
    result_string += '+' unless result_string.empty? || component[:coefficient] < 0
    result_string += '-' if component[:coefficient] == -1 && component[:variable]
    result_string += component[:coefficient].to_s unless [1, -1].include?(component[:coefficient]) && component[:variable]
    result_string += component[:variable].to_s if component[:variable]
    result_string += "^#{component[:exponent]}" if component[:exponent] > 1
    result_string
  end
end
