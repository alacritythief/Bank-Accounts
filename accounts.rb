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
      false
    else
      true
    end
  end

  def summary
    print "$#{Bank.currency(amount.abs)}  \t"
    if self.deposit? == true
      print "DEPOSIT"
    else
      print 'WITHDRAWAL'
    end
    puts " \t #{date} - #{description}"
  end
end


class Account
  attr_reader :starting_balance, :summary, :name
  attr_accessor :transactions, :current_balance

  def initialize(account)
    @transactions = []
    @starting_balance = account[:balance].to_f
    @current_balance = starting_balance
    @name = account[:account]
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


class Bank
  def self.results
    @accounts = self.build

    @accounts.each do |account|
      puts "\n==== #{account.name} ======================================="
      puts "\nStarting Balance: $#{Bank.currency(account.starting_balance)}"
      puts "Ending Balance: $#{Bank.currency(account.current_balance)}"
      puts
      puts "#{account.summary}"
      puts "==============================================================="
    end
  end

  def self.build(raw_accounts = Import.accounts, raw_transactions = Import.transactions)
    @accounts = []
    raw_accounts.each do |account|
      @accounts << account_pick = Account.new(account)
        raw_transactions.each do |transaction|
          if transaction[:account] == account_pick.name
            account_pick.transactions << Transaction.new(transaction)
          end
        end
    end
    @accounts
  end

  def self.currency(money)
    sprintf('%.2f', money)
  end
end

Bank.results
