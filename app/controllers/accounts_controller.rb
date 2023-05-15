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
        unless params[:destination].empty?
            @existing_account = @@initial_data.select {|account| account[:id] == params[:destination]}
        else
            @existing_account = @@initial_data.select {|account| account[:id] == @account}
        end
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
            if check_account.empty?
                @@initial_data.push({"id": params[:destination], "amount": params[:amount]})
                @response_hash[:destination] = {"id": params[:destination], "amount": params[:amount]}
            else
                check_account
                sum
            end
        when 'withdraw'
            check_account
            substract
        when "transfer"
            @account = params[:origin]
            check_account
            substract
            @account = params[:destination]
            check_account
            sum
        else
            @status_type = 'not_found'
        end

        render json: @response_hash, status: @status_type.to_sym
    end
end
