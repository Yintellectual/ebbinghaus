function sm2 () {
  let interval = 1
  let days_to_review = [0]
  for (let i=0; i<50; i++){
    let last_day_of_review = days_to_review[days_to_review.length-1]
    days_to_review.push(last_day_of_review+interval)
    interval *= 1.8
    if(interval > 800){
      break
    }
  }
  let floored_days_to_review = days_to_review.map((i)=>Math.round(i))
  return floored_days_to_review
}
