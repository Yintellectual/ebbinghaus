export class Memory {
  ID: number = 0;
  NAME: string = '';
  DATE: number = 0;
  DESCRIPTION: string = '';
  IS_ENABLED: boolean = true;
  IMAGES: string[] = [];

  toString(): string {
    return `Memory [
      ID:          ${this.ID}
      Name:        "${this.NAME}"
      Date:        ${new Date(this.DATE).toLocaleString()}
      Description: "${this.DESCRIPTION}"
      Status:      ${this.IS_ENABLED ? 'Enabled' : 'Disabled'}
      Images:      ${this.IMAGES.length > 0 ? `[${this.IMAGES.length}] ${this.IMAGES.join(', ')}` : 'No images'}
    ]`.replace(/^\s+/gm, ''); // Remove leading whitespace from each line
  }
}