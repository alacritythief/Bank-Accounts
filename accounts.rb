require 'csv'

ACCOUNTS = 'balances.csv'
TRANSACTIONS = 'bank_data.csv'

class Import
  attr_reader :accounts, :transactions

  def self.accounts(file = ACCOUNTS)
    accounts = []
    CSV.foreach(file, headers: true, header_converters: :symbol, converters: :numeric) do |row|
      accounts << row.to_hash
    end

    accounts
  end

  def self.transactions(file = TRANSACTIONS)
    transactions = []
    CSV.foreach(file, headers: true, header_converters: :symbol, converters: :numeric ) do |row|
      transactions << row.to_hash
    end

    transactions
  end
end


class Transaction
  attr_reader :date, :amount, :summary, :account, :description

  def initialize(transaction)
    @date = transaction[:date]
    @amount = transaction[:amount]
    @description = transaction[:description]
    @account = transaction[:account]
  end

  def deposit?
    if amount < 0
      true
    else
      false
    end
  end

  def summary
    puts "$#{currency(amount.abs)} \t#{self.deposit? ? 'WITHDRAWAL' : 'DEPOSIT'} \t #{date} - #{description}"
  end

  def currency(money)
    sprintf('%.2f', money)
  end
end



class Account
  attr_reader :starting_balance, :summary, :transactions, :name
  attr_accessor :current_balance

  def initialize(account)
    @transactions = []
    @starting_balance = account[:balance].to_f
    @name = account[:account]
    @current_balance = starting_balance
  end

  def current_balance
    transactions.each do |transaction|
      @current_balance += transaction.amount
    end
    @current_balance
  end

  def summary
    transactions.each do |transaction|
      transaction.summary
    end
    return nil
  end
end


class Results

  def self.run
    @accounts = self.build

    @accounts.each do |account|
      puts "\n===== #{account.name} ====="
      puts "Starting Balance: $#{self.currency(account.starting_balance)}"
      puts "Ending Balance: $#{self.currency(account.current_balance)}"
      puts "#{account.summary}"
      puts "============================"
    end
  end

  def self.currency(money)
    sprintf('%.2f', money)
  end

  def self.build(raw_accounts = Import.accounts, raw_transactions = Import.transactions)
    @accounts = []
    raw_accounts.each do |account|
      account_pick = Account.new(account)
      @accounts << account_pick
        raw_transactions.each do |transaction|
          if transaction[:account] == account_pick.name
            account_pick.transactions << Transaction.new(transaction)
          end
        end
    end
    @accounts
  end
end

Results.run
