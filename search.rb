module TelnetOPAC
  class Search
    def Search.title(screen, backend)
      inputbox = screen.new_inputbox("TITLE Search", "Enter title of book to search for below.")
      search = inputbox.get_entry
      waitbox = screen.new_messagebox "Retrieving catalog results, please wait..."
      waitbox.show
      results = backend.biblio_search search, :title
      waitbox.hide

      result_list = screen.new_infolist("Your Search: #{search}", 2)
      result_list.left_heading = "AUTHOR/TITLE"
      result_list.right_heading = "DATE"
      results.each do |result|
        author = result[:author]
        author += ", #{result[:author_dates]}" if result[:author_dates]
        publication_date = result[:publication_date] ? result[:publication_date].gsub(/[^0-9]/, "") : ""
        result_list.add_item [[result[:author], publication_date], [result[:title], ""]]
      end
      response = result_list.get_response
      Display.holdings(screen, results[response][:title], results[response][:holdings])
    end
  end
end
