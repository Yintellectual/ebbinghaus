export function utc_to_timezone(timezone_offset: number, timestamp: number){
  return timestamp + timezone_offset_ms(timezone_offset)
}
export function timezone_to_utc(timezone_offset: number, timestamp: number){
  return timestamp - timezone_offset_ms(timezone_offset)
}
function timezone_offset_ms(timezone_offset: number){
  return timezone_offset * 60 * 60 * 1000
}