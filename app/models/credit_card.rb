class CreditCard < ApplicationRecord
    validates :digits, presence :true
    validates :mount, presence :true, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 12}
    validates :year, presence :true, numericality: {greater_than_or_equal_to: DateTime.now.year}
    
end