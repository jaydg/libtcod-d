/*
* libtcod 1.5.1
* Copyright (c) 2008,2009,2010,2012 Jice & Mingos
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * The name of Jice or Mingos may not be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY JICE AND MINGOS ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL JICE OR MINGOS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

module tcod.list;

import tcod.c.functions;
import tcod.c.types;

/**
 All purposes container

 This is a fast, lightweight and generic container template, that provides
 array, list and stack paradigms.
 */

class TCODList(T) {
    T[] array;
    int fillSize;
    int allocSize;

public :
    /**
    Creating a list using the default constructor.

    You can create an empty list with the default constructor.

    Example:
    ---
    TCODList!int intList;
    TCODList!float* floatList = new TCODList!float();
    ---
    */
    this() {
    }

    /**
    Duplicating an existing list

    You can create a list by duplicating an existing list.

    Params:
        l = Existing list to duplicate.

    */
    this(TCOD_list_t l) {
        for (void **it = TCOD_list_begin(l); it != TCOD_list_end(l); it++) {
            push(*(cast(T *)(it)));
        }
    }

    ///
    unittest {
        TCODList!int intList;
        intList.push(3);
        intList.push(5);

        // intList2 contains two elements : 3 and 5
        TCODList!int intList2(intList);

        assert(2 == intList2.size);
        assert(3 == intList.first);
        assert(5 == intList.end);
    }

    /**
    Preallocating memory

    You can also create an empty list and pre-allocate memory for elements.
    Use this if you know the list size and want the memory to fit it perfectly.

    Params:
        nbElements = Allocate memory for nbElements.

    Example:
    ---
    // create an empty list, pre-allocate memory for 5 elements
    TCODList!int intList(5);
    ---
    */
    this(int nbElements) {
        allocSize = nbElements;
        array = new T[nbElements];
    }

    /**
    Deleting a list

    You can delete a list, freeing any allocated resources. Note that deleting
    the list does not delete it's elements. You have to use clearAndDelete
    before deleting the list if you want to destroy the elements too.

    Example:
    ---
    TCODList!int *intList = new TCODList!int(); // allocate a new empty list
    intList.push(5); // the list contains 1 element at position 0, value = 5
    delete intList; // destroy the list
    ---
    */
    ~this() {
        if (array) {
            destroy(array);
        }
    }

    /**
    Setting an element.

    You can assign a value with set. If needed, the array will allocate new
    elements up to idx.

    Params:
        elt = Element to put in the array.
        idx = Index of the element.
              0 <= idx
    */
    void set(const T elt, int idx) {
        if (idx < 0) {
            return;
        }

        while (allocSize < idx + 1) {
            allocate();
        }

        array[idx] = cast(T)elt;

        if (idx + 1 > fillSize) {
            fillSize = idx + 1;
        }
    }

    ///
    unittest {
        TCODList!int intList;   // the array is empty (contains 0 elements)
        intList.set(5, 0);      // the array contains 1 element at position 0, value = 5
        intList.set(7, 2);      // the array contains 3 elements : 5, 0, 7

        assert (2 == intList.size);
        assert(true == intList.contains(5));
        assert(true == intList.contains(0));
        assert(true == intList.contains(7));
    }


    /**
    Getting an element value

    You can retrieve a value with get.

    Params:
        idx = Index of the element.
              0 <= idx < size of the array

    */
    T get(int idx) {
        return array[idx];
    }

    ///
    unittest {
        TCODList!int intList;
        intList.set(5, 0);
        assert(5 == intList.get(0));
    }

    /**
    Checking if a list is empty
    */
    bool isEmpty() {
        return (fillSize == 0);
    }

    ///
    unittest {
        TCODList!int intList;
        assert(intList.isEmpty);

        intList.set(3, 0);
        assert(false == intList.isEmpty);
    }

    /**
    Getting the list size
    */
    int size() const {
        return fillSize;
    }

    ///
    unittest {
        TCODList!int intList;
        assert(0 == intList.size);

        intList.set(3, 0);
        assert(1 == intList.size);
    }

    /**
    Checking if an element is in the list

    Params:
        elt = The element.
    */
    bool contains(const T elt) {
        for (T* curElt = begin(); curElt != end(); curElt++) {
            if (*curElt == elt) {
                return true;
            }
        }

        return false;
    }

    ///
    unittest {
        TCODList!int intList;
        intList.set(3, 0);
        assert(true == intList.contains(3));
        assert(false == intList.contains(4));
    }

    /**
    Insert an element in the list

    Params:
        elt = Element to insert in the list.
        idx = Index of the element after the insertion.
              0 <= idx < list size

    */
    T* insertBefore(const T elt, int before) {
        if (fillSize + 1 >= allocSize) {
            allocate();
        }

        for (int idx = fillSize; idx > before; idx--) {
            array[idx] = array[idx-1];
        }

        array[before] = cast(T)elt;
        fillSize++;
        return &array[before];
    }

    ///
    unittest {
        TCODList!int intList;       // the list is empty (contains 0 elements)
        intList.set(0, 5);          // the list contains 1 element at position 0, value = 5
        intList.insertBefore(2, 0); // the list contains 2 elements : 2, 5
    }

    /**
    Removing an element from the list

    The _fast versions replace the element to remove with the last element of
    the list. They're faster, but do not preserve the list order.

    Params:
        elt = The element to remove
    */
    void remove(const T elt) {
        for (T* curElt = begin(); curElt != end(); curElt ++) {
            if (*curElt == elt) {
                remove(curElt);
                return;
            }
        }
    }

    ///
    unittest {
        TCODList!int intList;       // the list is empty (contains 0 elements)
        intList.set(0, 5);          // the list contains 1 element at position 0, value = 5
        assert(1 == intList.size);

        intList.remove(5);          // the list is empty
        assert(true == intList.isEmpty);
    }

    /** ditto */
    void removeFast(const T elt) {
        for (T* curElt = begin(); curElt != end(); curElt ++) {
            if (*curElt == elt) {
                removeFast(curElt);
                return;
            }
        }
    }

    /**
    Concatenating two lists

    You can concatenate two lists. Every element of l will be added to current
    list:

    Params:
        l = the list handler containing elements to insert.
    */
    void addAll(TCODList!T l) {
        for (T* t = l.begin(); t != l.end(); t++) {
            push(*t);
        }
    }

    ///
    unittest {
        TCODList!int intList;
        intList.set(1, 3);          // intList contains 2 elements : 0, 3
        TCODList!int intList2;      // intList2 is empty
        intList2.set(0, 1);         // intList2 contains 1 element : 1
        intList2.addAll(intList);   // intList2 contains 3 elements : 1, 0, 3

        assert(3 = initList2.size);
        assert(true == intList2.contains(1));
        assert(true == intList2.contains(0));
        assert(true == intList2.contains(3));
    }

    /**
    Emptying a list
    */
    void clear() {
        fillSize = 0;
    }

    ///
    unittest {
        TCODList!int intList;
        intList.set(0, 3);  // intList contains 1 element
        assert(1 == intList.size);

        intList.clear();    // intList is empty
        assert(0 == intList.size);
    }

    /**
    Emptying a list and destroying its elements

    For lists containing pointers, you can clear the list and delete the elements:

    Example:
    ---
    TCODList!MyClass intList;
    MyClass cl = new MyClass(); // new instance of MyClass allocated here
    intList.set(0, cl);
    intList.clear(); // the list is empty. cl is always valid
    intList.set(0, cl);
    intList.clearAndDelete(); // the list is empty. delete cl has been called. The address cl is no longer valid.
    ---
    */
    void clearAndDelete() {
        for (T* curElt = begin(); curElt != end(); curElt ++) {
            destroy(*curElt);
        }
        fillSize=0;
    }

    /**
    Reversing a list

    This function reverses the order of the elements in the list.

    */
    void reverse() {
        T* head = begin();
        T* tail = end();
        while (head < tail) {
            T tmp = *head;
            *head = *tail;
            *tail = tmp;
            head++;
            tail--;
        }
    }

    ///
    unittest {
        TCODList!int intList;   // the list is empty (contains 0 elements)
        intList.push(5);        // the list contains 1 element at position 0, value = 5
        intList.push(2);        // the list contains 2 elements : 5,2
        intList.reverse();      // now order is 2,5

        assert(2 == iniList.first);
        assert(5 == intList.end);
    }

    /**
    Pushing an element on the stack

    You can push an element on the stack (append it to the end of the list):

    Params:
        elt = Element to append to the list.

    */
    void push(const T elt) {
        if (fillSize + 1 >= allocSize) {
            allocate();
        }

        array[fillSize++] = cast(T)elt;
    }

    ///
    unittest {
        TCODList!int intList;   // the list is empty (contains 0 elements)
        intList.push(5);        // the list contains 1 element at position 0, value = 5
        intList.push(2);        // the list contains 2 elements : 5, 2

        assert(5 == intList.first);
        assert(2 == intList.end);
    }

    /**
    Poping an element from the stack

    You can pop an element from the stack (remove the last element of the list).
    */
    T pop() {
        if (fillSize == 0) return T.init;
        return array[--fillSize];
    }

    ///
    unittest {
        TCODList!int intList;   // the list is empty (contains 0 elements)
        intList.push(5);        // the list contains 1 element at position 0, value = 5
        intList.push(2);        // the list contains 2 elements : 5,2
        assert (2 == intList.size);

        int val = intList.pop(); // val == 2, the list contains 1 element : 5
        assert (2 == val);
        assert (1 == intList.size);

        val = intList.pop();    // val == 5, the list is empty
        assert (5 == val);
        assert (intList.isEmpty);
    }

    /**
    Peeking the last element of the stack

    You can read the last element of the stack without removing it:
    */
    T peek() {
        if (fillSize == 0) {
            return T.init;
        }

        return array[fillSize - 1];
    }

    ///
    unittest {
        TCODList!int intList;
        intList.push(3);            // intList contains 1 elements : 3

        int val = intList.peek();   // val == 3, inList contains 1 elements : 3
        assert (3 == val);

        intList.push(2);            // intList contains 2 elements : 3, 2
        val = intList.peek();       // val == 2, inList contains 2 elements : 3, 2
        assert (2 == intList.size);
        assert (2 == val);
    }

    /**
    You can iterate through the elements of the list using an iterator. begin()
    returns the address of the first element of the list. You go to the next
    element using the increment operator ++. When the iterator's value is equal
    to end(), you've gone through all the elements. <b>Warning! You cannot
    insert elements in the list while iterating through it. Inserting elements
    can result in reallocation of the list and your iterator will not longer be valid.</b>
    */
    T* begin() {
        if (fillSize == 0) {
            return null;
        }

        return &array[0];
    }

    /** ditto */
    T* end() {
        if (fillSize == 0) {
            return null;
        }

        return &array[fillSize];
    }

    ///
    unittest {
        TCODList!int intList;   // the list is empty (contains 0 elements)
        intList.push(5);        // the list contains 1 element at position 0, value = 5
        intList.push(2);        // the list contains 2 elements : 5, 2
        for (int *iterator = intList.begin; iterator != intList.end; iterator ++) {
            int currentValue = *iterator;

            if (intList.begin == iterator) {
                assert (5 == currentValue);
            }

            if (intList.end == iterator) {
                assert (2 == currentValue);
            }
        }
    }

    /**
    You can remove an element from the list while iterating. The element at the
    iterator position will be removed. The function returns the new iterator.
    The _fast versions replace the element to remove with the last element of
    the list. They're faster, but do not preserve the list order.

    Params:
        iterator = The list iterator.
    */
    T* remove(T* elt) {
        for (T* curElt = elt; curElt < end() - 1; curElt++) {
            *curElt = *(curElt + 1);
        }

        fillSize--;
        if (fillSize == 0) {
            return null;
        } else {
            return elt-1;
        }
    }

    /** ditto */
    T* removeFast(T* elt) {
        *elt = array[fillSize - 1];
        fillSize--;

        if ( fillSize == 0 ) {
            return null;
        } else {
            return elt - 1;
        }
    }

    ///
    unittest {
        TCODList!int intList;   // the list is empty (contains 0 elements)
        intList.push(5);        // the list contains 1 element at position 0, value = 5
        intList.push(2);        // the list contains 2 elements : 5, 2
        intList.push(3);        // the list contains 3 elements : 5, 2, 3

        immutable int[] expectedValues = [5, 2, 3];

        for (int* iterator = intList.begin(); iterator != intList.end(); iterator++) {
            int currentValue = *iterator;
            if (currentValue == 2) {
                // remove this value from the list and keep iterating on next element (value == 3)
                iterator = intList.remove(iterator);
            }

            assert (expectedValues[idx] == currentValue);
        }
        assert (2 == intList.size); // now the list contains only two elements : 5,3
    }

protected :
    void allocate() {
        int newSize = allocSize * 2;
        if (newSize == 0) newSize = 16;
        T[] newArray = new T[newSize];

        if (array) {
            if (fillSize > 0) {
                newArray[0..fillSize] = array[0..fillSize];
            }

            destroy(array);
        }

        array = newArray;
        allocSize = newSize;
    }
}
