class_name MinHeap

var heap: Array[Vector2i]
var initial_position: Vector2i

func get_distance(position: Vector2i) -> float:
	return sqrt(pow(initial_position.x - position.x, 2) + pow(initial_position.y - position.y, 2))

func heapify(i: int = 0):
	var largest = i
	var leftChild = 2*largest + 1
	var rightChild = 2*largest + 2

	if leftChild < heap.size() and get_distance(heap[leftChild]) < get_distance(heap[largest]):
		largest = leftChild

	if rightChild < heap.size() and get_distance(heap[rightChild]) < get_distance(heap[largest]):
		largest = rightChild

	if largest != i:
		var temp = heap[i]
		heap[i] = heap[largest]
		heap[largest] = temp
		heapify(largest)

func push(item: Vector2i):
	heap.append(item)
	for i in range((heap.size()/2)-1, -1, -1):
		heapify(i)


func push_array(items: Array[Vector2i]):
	for item in items:
		heap.append(item)
		for i in range((heap.size()/2)-1, -1, -1):
			heapify(i)

func peek() -> Vector2i:
	return heap[0]

func pop() -> Vector2i:
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
