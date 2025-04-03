const REVIEW_INTERVALS = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]
export class Repetition{
  MEMORY_ID : number = 0;
  LAST_VIEWED_TIMESTAMP: number = Date.now();
  TIMES_REVIEWED: number = 0;
  NEXT_REVIEWED_TIMESTAMP: number = 0;
  IS_ACTIVATED: boolean = true;

  constructor(memory_id: number) {
    this.MEMORY_ID = memory_id;
    this.LAST_VIEWED_TIMESTAMP = Date.now();
    this.TIMES_REVIEWED = 0;
    this.NEXT_REVIEWED_TIMESTAMP = this.calculate_next_review_timestamp();
    this.IS_ACTIVATED = true;
  }
  public addDaysToTimestamp(timestamp: number, days: number): number {
    const date = new Date(timestamp); // Convert timestamp to Date object
    date.setDate(date.getDate() + days); // Add days
    return date.getTime(); // Convert back to timestamp
  }

  public calculate_next_review_timestamp(){
    return this.addDaysToTimestamp(this.LAST_VIEWED_TIMESTAMP, REVIEW_INTERVALS[this.TIMES_REVIEWED])
  }

  public review(){
    this.TIMES_REVIEWED += 1
    if(this.TIMES_REVIEWED > REVIEW_INTERVALS.length){
      this.IS_ACTIVATED = false
    }
    this.LAST_VIEWED_TIMESTAMP = Date.now()
    this.NEXT_REVIEWED_TIMESTAMP = this.calculate_next_review_timestamp()
  }

  toString(): string {
    return `Repetition {
      MEMORY_ID: ${this.MEMORY_ID},
      LAST_VIEWED_TIMESTAMP: ${this.LAST_VIEWED_TIMESTAMP},
      TIMES_REVIEWED: ${this.TIMES_REVIEWED},
      NEXT_REVIEWED_TIMESTAMP: ${this.NEXT_REVIEWED_TIMESTAMP},
      IS_ACTIVATED: ${this.IS_ACTIVATED}
    }`;
  }
}