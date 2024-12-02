import "@hotwired/turbo-rails"
import "controllers";
import "bootstrap";
import Rails from "@rails/ujs";
Rails.start();
import { togglePasswordVisibility } from "utils/passwordToggle";
import "utils/masks"
import "utils/fetchAddress"
import "utils/sweetalert_confirm"
import "utils/sweetalert_confirm_delete"
import "utils/sweetalert_confirm_save"
import "utils/sweetalert_info"
import "utils/sidebarControll"

const initializePasswordToggle = () => {
    document.querySelectorAll('.password-toggle').forEach((button) => {
        button.removeEventListener('click', togglePasswordClickHandler);
        button.addEventListener('click', togglePasswordClickHandler);
    });
};

const togglePasswordClickHandler = (event) => {
    const button = event.currentTarget;
    const targetClass = button.getAttribute('data-target-class');
    togglePasswordVisibility(targetClass);
};

["turbo:load", "turbo:render"].forEach((event) => {
    document.addEventListener(event, initializePasswordToggle);
});
