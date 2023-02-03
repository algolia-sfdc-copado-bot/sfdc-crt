from __future__ import annotations
from datetime import datetime
from dateutil.relativedelta import relativedelta

def relative_date(date_data: list, format: str = "%m/%d/%Y", shift_date_time: int = 0) -> str:
    """ Takes in list containing (years, months, days), adds them to todays date and returns the date string
    format parameter allows changing the returned date: https://docs.python.org/3/library/datetime.html#strftime-and-strptime-format-codes
    shift_date_time parameter is used to fix dates between different timezones
    """
    today = datetime.now()
    if today.hour < shift_date_time:
        today = today - relativedelta(day=1)
    
    date = today + relativedelta(years=int(date_data[0]), months=int(date_data[1]), days=int(date_data[2]))
    return date.strftime(format)