require 'progress_bar'
require 'set'
require 'csv'

class DuplicateTicketChecker
  def initialize(tickets)
    @tickets = tickets
    @tickets_by_ticket_num = Hash.new { |hash, key| hash[key] = [] }
    @duplicate_ticket_nums = Set.new
    @conflict_count = 0
  end

  def check!
    SRDM::LOG.info "Checking file for duplicate ticket numbers"
    look_for_duplicates
    if @conflict_count > 0
      output_duplicates
      kill_script
    end
  end

  private

  def output
    @output ||= CSV.open("./tmp/#{SRDM.subdomain}-duplicate_tickets-#{Date.today}.csv", 'w')
  end

  def output_duplicates
    output << ['Ticket #', 'Date', 'Customer #']
    @duplicate_ticket_nums.each do |ticket_num|
      @tickets_by_ticket_num[ticket_num].each do |ticket|
        output << [ticket_num, ticket.completed_at, ticket.customer_public_id]
      end
    end
  end

  def look_for_duplicates
    bar = ProgressBar.new @tickets.count
    @tickets.each do |ticket|
      if @tickets_by_ticket_num[ticket.ticket_number].count > 0
        @conflict_count += 1
        @duplicate_ticket_nums << ticket.ticket_number
      end
      @tickets_by_ticket_num[ticket.ticket_number] << ticket
      bar.increment!
    end
  end

  def kill_script
    SRDM::LOG.error "Found #{@conflict_count} duplicate ticket numbers. Please resolve the issues on your file."
    SRDM::LOG.error "Duplicate tickets saved to file #{@output.path}" if @conflict_count > 0
    abort
  end
end
