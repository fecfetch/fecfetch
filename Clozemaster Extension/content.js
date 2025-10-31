function cleanUpModals() {

  document.querySelectorAll(".modal.clozemaster.text-left.fade.in").forEach(modal => {
      modal.style.display = "";
  });


  document.querySelectorAll(".modal-backdrop.fade.in.modal-stack").forEach(backdrop => {
    backdrop.remove();
  });
  document.querySelectorAll(".modal.clozemaster.text-left.fade.in").forEach(modal => {
    if (modal.style.display === "block") {
      modal.style.display = "";
    }
  });
}


window.addEventListener("load", cleanUpModals);


const observer = new MutationObserver(cleanUpModals);
observer.observe(document.body, { childList: true, subtree: true });


document.addEventListener("click", event => {
  const btn = event.target.closest(".btn.btn-lg.btn-success.next.joystix");
  if (btn) {
    setTimeout(cleanUpModals, 100);
  setTimeout(cleanUpModals, 500);
  }
});
document.addEventListener("keydown", event => {
  if (event.key === "Enter") {
    const submitBtn = document.querySelector(".btn.btn-success.joystix.btn-lg");
    if (submitBtn) {
      setTimeout(cleanUpModals, 100);
  setTimeout(cleanUpModals, 500);
    }
  }
});
