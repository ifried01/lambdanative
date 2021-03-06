#|
LambdaNative - a cross-platform Scheme framework
Copyright (c) 2009-2013, University of British Columbia
All rights reserved.

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the
following conditions are met:

* Redistributions of source code must retain the above
copyright notice, this list of conditions and the following
disclaimer.

* Redistributions in binary form must reproduce the above
copyright notice, this list of conditions and the following
disclaimer in the documentation and/or other materials
provided with the distribution.

* Neither the name of the University of British Columbia nor
the names of its contributors may be used to endorse or
promote products derived from this software without specific
prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#

;; very simple unit testing framework
;; this can be used to test cases in code
;; API
;; (unit-test <unit-name> <test-name> <test-proc>)
;; (unit-test <unit-name>)
;; (unit-test-all)

(define unit-test:table (make-table init: #f))

(define (unit-test n . x)

  ;; add a test to the test group
  (define (unit-test-add n tn tp)
    (let* ((t (table-ref unit-test:table n))
          (tt (if (table? t) t (make-table init: #f))))
      (table-set! tt tn tp)
      (table-set! unit-test:table n tt)))

  ;; run a test and catch all errors
  (define (unit-test-try p)
    (let ((outcome 
       (with-exception-catcher (lambda (e) #f)
         (lambda () (p)))))
      (if outcome "OK" "FAIL")))

  ;; run all tests with-in a group
  (define (unit-test-run n)
    (let ((t (table-ref unit-test:table n)))
      (if (table? t)
        (table-for-each (lambda (tn tp) 
          (log-status n ": " tn ".. " (unit-test-try tp))) t)
        (log-status n ": no tests found."))))

  (if (> (length x) 0)
    (apply unit-test-add (append (list n) x))
    (unit-test-run n)))

(define (unit-test-all) 
  (table-for-each (lambda (k v)
     (unit-test k)) unit-test:table))

;; eof
