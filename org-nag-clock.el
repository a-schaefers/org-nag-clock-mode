;;; -*- lexical-binding: t; -*-

;; MIT License

;; Copyright 2018 Adam Schaefers sch@efers.org

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;; Make Emacs remind (nag) you to clock-in to the org-mode timeclock

(defgroup org-nag-clock nil
  "Nag org users to immediately perform a task (like clock-in)."
  :group 'notifiers)

(defcustom org-nag-clock-grace-period 10
  "Seconds of emacs uptime before nag messages will be sent."
  :group 'org-nag-clock
  :type 'number)

(defcustom org-nag-clock-message "Clock in to org-mode!"
  "Nag message for `org-nag-clock-router'"
  :group 'org-nag-clock
  :type 'string)

(defcustom org-nag-clock-notify-command nil
  "Command to be used for notifications.
Automatically set to \"notify-send\" if found on path and variable uncustomized.
If nil it falls back to use Emacs built-in `message'"
  :group 'org-nag-clock
  :type 'string)

;; [if] `org-nag-clock-notify-command' is nil [and] notify-send is on path
;; [then] set `org-nag-clock-notify-command' to notify-send
;; [else] [if] `org-nag-clock-notify-command' is nil [then] use `message'
;; finally therefore, if `org-nag-clock-notify-command' is customized by the user it remains customized.
(if (progn (and (string= org-nag-clock-notify-command nil)
                (executable-find "notify-send")))
    (setq org-nag-clock-notify-command "notify-send")
  (if (string= org-nag-clock-notify-command nil)
      (setq org-nag-clock-notify-command "message")))

(defun org-nag-clock-notification-sender (x)
  "Sends an alert using `org-nag-clock-notify-command' and `org-nag-clock-message'"
  (if (string= "message" org-nag-clock-notify-command)
      (message x)
    (start-process org-nag-clock-notify-command nil org-nag-clock-notify-command x)))

(defun org-nag-clock-router ()
  "`org-nag-clock' runs tests to see if a notification should be sent
and routes the notification."
  (if (> (string-to-number (emacs-uptime "%s")) org-nag-clock-grace-period)
      (if (org-clocking-p) nil
        (org-nag-clock-notification-sender org-nag-clock-message))))

;;;###autoload
(define-minor-mode org-nag-clock-mode
  "Toggles Org Nag mode."
  :global t
  :group 'org-nag-clock
  (if (not org-nag-clock-mode)
      (remove-hook 'prog-mode-hook 'org-nag-clock-router)
    (progn
      (require 'org-clock)
      (add-hook 'prog-mode-hook 'org-nag-clock-router))))

(provide 'org-nag-clock)
