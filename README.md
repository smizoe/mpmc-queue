# mpmc-queue

[![Build Status](https://travis-ci.org/smizoe/mpmc-queue.svg?branch=master)](https://travis-ci.org/smizoe/mpmc-queue)

multiple-producer-multiple-consumer queue for emacs (>= 26.0).

Installation
============

You can start using this by putting `mpmc-queue.el` in your `load-path`.

How to Use
==========

You can create a mpmc queue with `mpmc-queue--create` function, and can enqueue or dequeue elements by `mpmc-queue-put` or `mpmc-queue-get` functions.
There is also `mpmc-queue-peek` function that returns the first element without removing it from the queue:

```emacs-lisp
;; queue creation
(setq-local q (mpmc-queue--create))

;; basic queue operations
(mpmc-queue-put q 1)
(mpmc-queue-peek q) ;; => 1
(mpmc-queue-get q) ;; => 1

(mpmc-queue-empty-p q) ;; => t

;; non-blocking vs. blocking
(mpmc-queue-get q t) ;; => nil
(mpmc-queue-get q) ;; => blocks until an element is available in the queue
```

`mpmc-queue-get` and `mpmc-queue-peek` functions take one optional argument (`non-blocking`).
If this optional argument is `t` and the queue is empty, these functions return `nil` immediately.
If the argument is `nil` and the queue is empty, these block until an element is available in the queue.


MPMC Queue Structure
====================

This queue has 3 fields:

- `internal-queue`: the internal queue defined in `queue.el`
- `mutex`: the mutex associated with this queue.
- `non-empty-condition`: the condition variable used to notify changes from the empty state to a non-empty state.

There is macro `mpmc-queue--with-mutex` which runs the given body while holding the mutex of a mpmc queue:

``` emacs-lisp
(setq-local q (mpmc-queue--create))
(mpmc-queue--with-mutex q
    ;; do whatever you want with the queue
    (...)
    )
```
