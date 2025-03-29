import { Memory } from "../../entities/Memory";

export class MemoryDataSource implements IDataSource{
  private memories: Array<Memory>  = []
  private listeners: DataChangeListener[] = [];

  constructor(initialData: Array<Memory>) {
    this.memories = initialData.slice();
  }

  totalCount(): number {
    return this.memories.length;
  }

  getData(index: number): Memory {
    return this.memories[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) === -1) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos !== -1) {
      this.listeners.splice(pos, 1);
    }
  }

  // Add an item
  addItem(item: Memory): void {
    this.memories.push(item);
    this.notifyDataAdd(this.memories.length - 1);
  }

  // Remove an item
  removeItem(index: number): void {
    if (index >= 0 && index < this.memories.length) {
      this.memories.splice(index, 1);
      this.notifyDataDelete(index);
    }
  }

  // Update an item
  updateItem(index: number, newItem: Memory): void {
    if (index >= 0 && index < this.memories.length) {
      this.memories[index] = newItem;
      this.notifyDataChange(index);
    }
  }

  // Reload all data
  reloadData(newData: Array<Memory>): void {
    this.memories = newData.slice();
    this.notifyDataReload();
  }

  private notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  private notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  private notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  private notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }
}