class HolidaySearch

    def holiday_info
        service.holidays[0..2].map do |data|
          HolidayData.new(data)
      end
    end

    def service
      HolidayService.new
    end
end