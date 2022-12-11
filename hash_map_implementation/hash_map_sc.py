"""
implementation of a hash map using separate chaining
"""

from hash_map_dependency import (DynamicArray, LinkedList,
                        hash_function_1, hash_function_2)

class HashMap:
    def __init__(self,
                 capacity: int = 11,
                 function: callable = hash_function_1) -> None:
        """
        Initialize new HashMap that uses
        separate chaining for collision resolution
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        self._buckets = DynamicArray()

        # capacity must be a prime number
        self._capacity = self._next_prime(capacity)
        for _ in range(self._capacity):
            self._buckets.append(LinkedList())

        self._hash_function = function
        self._size = 0

    def __str__(self) -> str:
        """
        Override string method to provide more readable output
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        out = ''
        for i in range(self._buckets.length()):
            out += str(i) + ': ' + str(self._buckets[i]) + '\n'
        return out

    def _next_prime(self, capacity: int) -> int:
        """
        Increment from given number and the find the closest prime number
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        if capacity % 2 == 0:
            capacity += 1

        while not self._is_prime(capacity):
            capacity += 2

        return capacity

    @staticmethod
    def _is_prime(capacity: int) -> bool:
        """
        Determine if given integer is a prime number and return boolean
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        if capacity == 2 or capacity == 3:
            return True

        if capacity == 1 or capacity % 2 == 0:
            return False

        factor = 3
        while factor ** 2 <= capacity:
            if capacity % factor == 0:
                return False
            factor += 2

        return True

    def get_size(self) -> int:
        """
        Return size of map
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        return self._size

    def get_capacity(self) -> int:
        """
        Return capacity of map
        DO NOT CHANGE THIS METHOD IN ANY WAY
        """
        return self._capacity

    def put(self, key: str, value: object) -> None:
        """
        updates the key/value pair in the hash table. if 'key' is already in the hash table, its corresponding value
        is updated to 'value', otherwise the key/value pair is added to the hash table.
        """

        # resize the hash table to double its current capacity if the current load factor is >= 1.0
        if self.table_load() >= 1.0:
            self.resize_table(self._capacity * 2)

        current_hash = self._hash_function(key)
        index = current_hash % self._capacity

        if self._buckets.get_at_index(index).contains(key) is not None:
            self._buckets.get_at_index(index).contains(key).value = value
        else:
            self._buckets.get_at_index(index).insert(key, value)
            self._size += 1

    def empty_buckets(self) -> int:
        """
        returns the number of empty buckets in the hash table
        """
        num_empty = 0
        for i in range(self._capacity):
            if self._buckets.get_at_index(i).length() == 0:
                num_empty += 1
        return num_empty

    def table_load(self) -> float:
        """
        returns the current hash table load factor
        """
        return self._size / self._capacity

    def clear(self) -> None:
        """
        clears the contents of the hash map
        """
        self._buckets = DynamicArray()
        for _ in range(self._capacity):
            self._buckets.append(LinkedList())
        self._size = 0

    def resize_table(self, new_capacity: int) -> None:
        """
        changes the capacity of the hash table to 'new_capacity' if 'new_capacity' is a prime number, or the next
        highest prime number if 'new_capacity' is not a prime number
        """

        # build a DynamicArray, 'new_buckets', and starting with the value passed as 'new_capacity' we increase
        # the value of 'new_capacity' until it is greater than our HashMap's size
        if new_capacity < 1:
            return
        if not self._is_prime(new_capacity):
            new_capacity = self._next_prime(new_capacity)

        new_buckets_size = 0
        for i in range(self._size):
            new_buckets_size += 1
            if new_buckets_size > new_capacity:
                new_capacity = self._next_prime(new_capacity * 2)

        new_buckets = DynamicArray()
        for i in range(new_capacity):
            new_buckets.append(LinkedList())

        # re-hash and add all the values of our HashMap into new_buckets
        for i in range(self._capacity):
            if self._buckets.get_at_index(i).length() == 0:
                pass
            else:
                for node in self._buckets.get_at_index(i):
                    new_hash = self._hash_function(node.key)
                    new_ind = new_hash % new_capacity
                    new_buckets.get_at_index(new_ind).insert(node.key, node.value)
        self._buckets = new_buckets
        self._capacity = new_capacity

    def get(self, key: str):
        """
        returns the value associated with 'key', if there is no value associated with 'key' it returns None
        """
        index = self._hash_function(key) % self._capacity
        if self._buckets.get_at_index(index).contains(key) is None:
            return None
        return self._buckets.get_at_index(index).contains(key).value

    def contains_key(self, key: str) -> bool:
        """
        returns True if the given key is in the hash map, otherwise it returns False
        """
        if self._size == 0:
            return False
        else:
            for i in range(self._capacity):
                if self._buckets.get_at_index(i).contains(key) is not None:
                    return True
        return False

    def remove(self, key: str) -> None:
        """
        removes 'key' and its associated value from the hash map
        """
        index = self._hash_function(key) % self._capacity
        if self._buckets.get_at_index(index).contains(key) is None:
            pass
        else:
            self._size -= 1
        self._buckets.get_at_index(index).remove(key)

    def get_keys_and_values(self) -> DynamicArray:
        """
        returns a dynamic array where each index contains a tuple of a key/value pair stored in the hash map
        """
        return_arr = DynamicArray()
        for i in range(self._capacity):
            if self._buckets.get_at_index(i).length() == 0:
                pass
            else:
                for node in self._buckets.get_at_index(i):
                    return_arr.append((node.key, node.value))
        return return_arr


def find_mode(da: DynamicArray) -> (DynamicArray, int):
    """
    returns a tuple containing a DynamicArray comprising the mode of 'da', and the integer value of the mode
    """

    # the value at each index of 'da' is used as the key in 'map' and the value is the current frequency
    # of each value
    map = HashMap(function=hash_function_2)

    # return_arr and return_arr_freq are used together to track the most-frequent value in 'da' and are updated
    # as we loop through 'da' and add each value to 'map'
    return_arr = None
    return_arr_freq = 0

    for i in range(da.length()):
        current_freq = map.get(da.get_at_index(i))
        if current_freq is None:
            map.put(da.get_at_index(i), 1)
            current_freq = 1
        else:
            map.put(da.get_at_index(i), current_freq + 1)
            current_freq = current_freq + 1


        # check to see how the frequency of da's current index's value compares to the current frequency
        # of the values in return_arr, and update return_arr and return_arr_freq as necessary
        if return_arr is None:
            return_arr = DynamicArray()
            return_arr.append(da.get_at_index(i))
            return_arr_freq = 1
        elif current_freq == return_arr_freq:
            return_arr.append(da.get_at_index(i))
        elif current_freq > return_arr_freq:
            return_arr = DynamicArray()
            return_arr.append(da.get_at_index(i))
            return_arr_freq = current_freq
        else:
            continue

    return (return_arr, return_arr_freq)
