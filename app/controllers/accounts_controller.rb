class AccountsController < ApplicationController
    @@initial_data = []

    def reset
        @@initial_data = []
        render status: :ok
    end

    def balance
        response_hash = Hash.new
        result = @@initial_data.select {|account| account[:id] == params[:account_id]}
        unless result.empty?
            response_hash[:destination] = result[0]
            status_type = 'ok'       
        else
            status_type = 'not_found'       
        end
        render json: response_hash, status: status_type.to_sym
    end

    def check_account
        @existing_account = @@initial_data.select {|account| account[:id] == @account}
    end   

    def sum 
        @existing_account[0][:amount] = @existing_account[0][:amount] + params[:amount]
        @response_hash[:destination] = @existing_account[0]
    end

    def substract
        @existing_account[0][:amount] = @existing_account[0][:amount] - params[:amount]
        @response_hash[:destination] = @existing_account[0]
    end

    def event
        @response_hash = Hash.new
        @status_type = 'created'         
        case params[:type]
        when 'deposit'
            @account = params[:destination]
            if check_account.empty?
                @@initial_data.push({"id": params[:destination], "amount": params[:amount]})
                @response_hash[:destination] = {"id": params[:destination], "amount": params[:amount]}
            else
                check_account
                sum
            end
        when 'withdraw'
            @account = params[:destination]
            check_account
            substract
        when "transfer"
            @account = params[:origin]
            check_account
            substract
            @response_hash[:destination].transform_keys! { |k| k == :amount ? :balance : k }
            results = @response_hash[:destination]
            
            @account = params[:destination]
            check_account
            sum
            results2 = @response_hash[:destination].transform_keys! { |k| k == :amount ? :balance : k }

            @response_hash = {}
            @response_hash[:origin] = results 
            @response_hash[:destination] = results2
        else
            @status_type = 'not_found'
        end

        render json: @response_hash, status: @status_type.to_sym
    end
end
