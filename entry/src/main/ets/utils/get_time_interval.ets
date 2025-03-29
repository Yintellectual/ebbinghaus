interface TimeInterval {
  start: number,
  end: number
}
export function getTimeInterval(n: number): TimeInterval{
  // Calculate the start date (n days ago at midnight)
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - n);
  startDate.setHours(0, 0, 0, 0);

  // Calculate the end date (midnight of the next day after the start date)
  const endDate = new Date(startDate);
  endDate.setDate(startDate.getDate() + 1);
  let time_interval : TimeInterval;
  time_interval = {
    start: startDate.getTime(),
    end: endDate.getTime()
  }

  return time_interval;
}