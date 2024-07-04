class_name MinHeap

var heap: Array[int]

func heapify(i: int = 0):
	var largest = i
	var leftChild = 2*largest + 1
	var rightChild = 2*largest + 2

	if leftChild < heap.size() and heap[leftChild] < heap[largest]:
		largest = leftChild

	if rightChild < heap.size() and heap[rightChild] < heap[largest]:
		largest = rightChild

	if largest != i:
		var temp = heap[i]
		heap[i] = heap[largest]
		heap[largest] = temp
		heapify(largest)

func push(item: int):
	heap.append(item)
	for i in range((heap.size()/2)-1, -1, -1):
		heapify(i)

func peek() -> int:
	return heap[0]

func pop() -> int:
	var temp = heap[-1]
	heap[-1] = heap[0]
	heap[0] = temp
	var ret = heap.pop_back()
	for i in range((heap.size()/2)-1, -1, -1):
		heapify(i)
	return ret

# for testing
func print():
	while heap.size() > 0:
		print(pop())