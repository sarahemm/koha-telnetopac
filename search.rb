module TelnetOPAC
  class Search
    def Search.title(screen, backend)
      inputbox = screen.new_inputbox("TITLE Search", "Enter title of book to search for below.")
      search = inputbox.get_entry
      waitbox = screen.new_messagebox "Retrieving catalog results, please wait..."
      waitbox.show
      results = backend.biblio_search search, :title
      waitbox.hide

      results_menu = screen.new_menu("TITLE Search", "Please select one of the results below.")
      idx = 0
      results.each do |result|
        results_menu.add_item idx, "#{result[:title]} #{result[:subtitle]}"
        idx += 1
      end
      results_menu.add_item :mainmenu, "Return to Main Menu"

      results_menu.get_response
    end
  end
end
