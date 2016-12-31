class MecabClient

  # テキストを与えてインスタンスを生成
  def initialize(text)
    @text = text
  end

  # テキストを与えると、単語とその品詞のハッシュを返却する
  def to_types
    words = {}
    result = `echo "#{@text}" | mecab -E "" | awk -F, '{print $1,$2}'`
    result.each_line do |word|
      sp = word.chomp.split(/\s/)
      words[sp[0]] = "#{sp[1]} #{sp[2]}"
    end
    return words
  end

  # 単語ごとに分割した配列を返却する
  # typeを指定すると、品詞を指定して取得できる
  def to_words(type = nil)
    words = []
    words_with_type = to_types
    if type
      words_with_type.select {|k , v| v.match(type)}.keys
    else
      words_with_type.keys
    end
  end

end
