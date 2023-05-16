class AccountsController < ApplicationController
    @@initial_data = []

    def reset
        @@initial_data = []
        render status: :ok
    end

    def balance
        @account = params[:account_id]
        unless valid_account.empty?
            response = valid_account[0][:balance]
            status_type = 'ok'       
        else
            response = 0
            status_type = 'not_found'       
        end
        render json: response, status: status_type.to_sym
    end

    def event
        @response_hash = Hash.new
        @status_type = 'created'   
        @account = params[:destination]  
        @amount = params[:amount]
        case params[:type]
        when 'deposit'
            if valid_account.empty?
                @@initial_data.push({"id": params[:destination], "balance": params[:amount]})
                @response_hash[:destination] = {"id": params[:destination], "balance": params[:amount]}
            else
                valid_account
                sum
            end
        when 'withdraw'
           unless valid_account.empty?
                subtract
           else
                @status_type = 'not_found'
                event_response = 0
           end
        when "transfer"
            valid_destination = valid_account
            
            @account = params[:origin] 
            valid_origin = valid_account

            unless valid_origin.empty? || valid_destination.empty?
                subtract
                @origin = @response_hash[:destination]  
                @account = params[:destination]

                sum
                @destination = @response_hash[:destination]
                
                @response_hash = {}
                @response_hash[:origin] = @origin 
                @response_hash[:destination] = @destination
            else
                @status_type = 'not_found'
                event_response = 0
            end
        else
            @status_type = 'not_found'
        end

        @response_hash.empty? ? @message = event_response : @message = @response_hash
            
        render json: @message, status: @status_type.to_sym
    end

    def valid_account
        @@initial_data.select {|account| account[:id] == @account}
    end  
    
    def sum
        valid_account[0][:balance] = valid_account[0][:balance] + @amount
        @response_hash[:destination] = valid_account[0]
    end

    def subtract
        valid_account[0][:balance] = valid_account[0][:balance] - @amount
        @response_hash[:destination] = valid_account[0]
    end
end
