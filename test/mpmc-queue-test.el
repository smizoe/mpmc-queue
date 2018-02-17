;;; mpmc-queue-test.el --- test code for mpmc-queue.el  -*- lexical-binding: t; -*-

;; Copyright (C) 2018

;; Author: Sho Mizoe <sho.mizoe@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Run tests:
;;

;;; Code:

(require 'ert)
(require 'mpmc-queue)

(defun generate-get-fn (mpmcq sym)
  "Return a function that gets from MPMCQ and set the value to the `symbol-value' of SYM."
  (lambda ()
    (setf (symbol-value sym) (mpmc-queue-get mpmcq))
    )
  )

(defun generate-peek-fn (mpmcq sym)
  "Return a function that peeks from MPMCQ and set the value to the `symbol-value' of SYM."
  (lambda ()
    (setf (symbol-value sym) (mpmc-queue-peek mpmcq))
    )
  )


(ert-deftest get-empty-queue ()
  "> calling `mpmc-queue-get' on an empty queue blocks."
  ;; we ensure the thread creation order by using let* instead of let
  (let* (
        (q (mpmc-queue--create))
        (get-worker (make-thread (generate-get-fn q 'actual) "get-thread"))
        (put-worker (make-thread (lambda ()
                                   (sleep-for 0.1)
                                   (mpmc-queue-put q 1)
                                   )
                                 "put thread"
                                 )
                    )
        )
    (should (= 1
               (progn
                 (thread-join get-worker)
                 (thread-join put-worker)
                 actual
                 )
               )
            )
    )
  )

(ert-deftest peek-empty-queue ()
  "> calling `mpmc-queue-peek' on an empty queue blocks."
  ;; we ensure the thread creation order by using let* instead of let
  (let* (
        (q (mpmc-queue--create))
        (peek-worker (make-thread (generate-peek-fn q 'actual) "peek-thread"))
        (put-worker (make-thread (lambda ()
                                   (sleep-for 0.1)
                                   (mpmc-queue-put q 1)
                                   )
                                 "put thread"
                                 )
                    )
        )
    (should (= 1
               (progn
                 (thread-join peek-worker)
                 (thread-join put-worker)
                 actual
                 )
               )
            )
    )
  )


(ert-deftest get-empty-queue-non-blocking ()
  "> calling `mpmc-queue-get' with non-nil `non-blocking' does not block"
  (let* (
        (q (mpmc-queue--create))
        )
    (should (null (mpmc-queue-get q t)))
    )
  )

(ert-deftest peek-empty-queue-non-blocking ()
  "> calling `mpmc-queue-peek' with non-nil `non-blocking' does not block"
  (let* (
        (q (mpmc-queue--create))
        )
    (should (null (mpmc-queue-peek q t)))
    )
  )

(ert-deftest check-empty-queue-p ()
  "> calling `mpmc-queue-empty-p' checks the emptiness correctly."
  (let ((q (mpmc-queue--create)))
    (should (mpmc-queue-empty-p q))
    (mpmc-queue-put q 1)
    (should (not (mpmc-queue-empty-p q)))
    )
  )
;;; mpmc-queue-test.el ends here
