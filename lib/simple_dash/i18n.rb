module SimpleDash 
  class I18n
    def self.t(key)
      key.to_s
    end

    def self.translate(key)
      t(key)
    end
  end
end
