import { ComponentFixture, TestBed } from '@angular/core/testing'

import { MailComponent } from './mail.component'
import { DatePipe } from '@angular/common'
import { provideHttpClientTesting } from '@angular/common/http/testing'
import { RouterTestingModule } from '@angular/router/testing'
import {
  NgbModule,
  NgbAlertModule,
  NgbModalRef,
  NgbModal,
} from '@ng-bootstrap/ng-bootstrap'
import { NgSelectModule } from '@ng-select/ng-select'
import { of, throwError } from 'rxjs'
import { routes } from 'src/app/app-routing.module'
import { MailAccount } from 'src/app/data/mail-account'
import { MailRule } from 'src/app/data/mail-rule'
import { IfOwnerDirective } from 'src/app/directives/if-owner.directive'
import { IfPermissionsDirective } from 'src/app/directives/if-permissions.directive'
import { PermissionsGuard } from 'src/app/guards/permissions.guard'
import { CustomDatePipe } from 'src/app/pipes/custom-date.pipe'
import { SafeHtmlPipe } from 'src/app/pipes/safehtml.pipe'
import { MailAccountService } from 'src/app/services/rest/mail-account.service'
import { MailRuleService } from 'src/app/services/rest/mail-rule.service'
import { ConfirmDialogComponent } from '../../common/confirm-dialog/confirm-dialog.component'
import { MailAccountEditDialogComponent } from '../../common/edit-dialog/mail-account-edit-dialog/mail-account-edit-dialog.component'
import { MailRuleEditDialogComponent } from '../../common/edit-dialog/mail-rule-edit-dialog/mail-rule-edit-dialog.component'
import { CheckComponent } from '../../common/input/check/check.component'
import { NumberComponent } from '../../common/input/number/number.component'
import { PasswordComponent } from '../../common/input/password/password.component'
import { PermissionsFormComponent } from '../../common/input/permissions/permissions-form/permissions-form.component'
import { PermissionsGroupComponent } from '../../common/input/permissions/permissions-group/permissions-group.component'
import { PermissionsUserComponent } from '../../common/input/permissions/permissions-user/permissions-user.component'
import { SelectComponent } from '../../common/input/select/select.component'
import { TextComponent } from '../../common/input/text/text.component'
import { PageHeaderComponent } from '../../common/page-header/page-header.component'
import { PermissionsDialogComponent } from '../../common/permissions-dialog/permissions-dialog.component'
import { PermissionsService } from 'src/app/services/permissions.service'
import { ToastService } from 'src/app/services/toast.service'
import { TagsComponent } from '../../common/input/tags/tags.component'
import { FormsModule, ReactiveFormsModule } from '@angular/forms'
import { EditDialogMode } from '../../common/edit-dialog/edit-dialog.component'
import { NgxBootstrapIconsModule, allIcons } from 'ngx-bootstrap-icons'
import { SwitchComponent } from '../../common/input/switch/switch.component'
import { provideHttpClient, withInterceptorsFromDi } from '@angular/common/http'
import { By } from '@angular/platform-browser'

const mailAccounts = [
  { id: 1, name: 'account1' },
  { id: 2, name: 'account2' },
]
const mailRules = [
  { id: 1, name: 'rule1', owner: 1, account: 1, enabled: true },
  { id: 2, name: 'rule2', owner: 2, account: 2, enabled: true },
]

describe('MailComponent', () => {
  let component: MailComponent
  let fixture: ComponentFixture<MailComponent>
  let mailAccountService: MailAccountService
  let mailRuleService: MailRuleService
  let modalService: NgbModal
  let toastService: ToastService
  let permissionsService: PermissionsService

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [
        MailComponent,
        PageHeaderComponent,
        IfPermissionsDirective,
        CustomDatePipe,
        ConfirmDialogComponent,
        CheckComponent,
        SafeHtmlPipe,
        SelectComponent,
        TextComponent,
        PasswordComponent,
        NumberComponent,
        MailAccountEditDialogComponent,
        MailRuleEditDialogComponent,
        IfOwnerDirective,
        TagsComponent,
        PermissionsUserComponent,
        PermissionsGroupComponent,
        PermissionsDialogComponent,
        PermissionsFormComponent,
        SwitchComponent,
      ],
      imports: [
        NgbModule,
        RouterTestingModule.withRoutes(routes),
        FormsModule,
        ReactiveFormsModule,
        NgbAlertModule,
        NgSelectModule,
        NgxBootstrapIconsModule.pick(allIcons),
      ],
      providers: [
        CustomDatePipe,
        DatePipe,
        PermissionsGuard,
        provideHttpClient(withInterceptorsFromDi()),
        provideHttpClientTesting(),
      ],
    }).compileComponents()

    mailAccountService = TestBed.inject(MailAccountService)
    mailRuleService = TestBed.inject(MailRuleService)
    modalService = TestBed.inject(NgbModal)
    toastService = TestBed.inject(ToastService)
    permissionsService = TestBed.inject(PermissionsService)
    jest.spyOn(permissionsService, 'currentUserCan').mockReturnValue(true)
    jest
      .spyOn(permissionsService, 'currentUserHasObjectPermissions')
      .mockReturnValue(true)
    jest
      .spyOn(permissionsService, 'currentUserOwnsObject')
      .mockReturnValue(true)

    fixture = TestBed.createComponent(MailComponent)
    component = fixture.componentInstance
    fixture.detectChanges()
  })

  function completeSetup(excludeService = null) {
    if (excludeService !== mailAccountService) {
      jest.spyOn(mailAccountService, 'listAll').mockReturnValue(
        of({
          all: mailAccounts.map((a) => a.id),
          count: mailAccounts.length,
          results: (mailAccounts as MailAccount[]).concat([]),
        })
      )
    }
    if (excludeService !== mailRuleService) {
      jest.spyOn(mailRuleService, 'listAll').mockReturnValue(
        of({
          all: mailRules.map((r) => r.id),
          count: mailRules.length,
          results: (mailRules as MailRule[]).concat([]),
        })
      )
    }

    fixture = TestBed.createComponent(MailComponent)
    component = fixture.componentInstance
    fixture.detectChanges()
  }

  it('should show errors on load if load mailAccounts failure', () => {
    const toastErrorSpy = jest.spyOn(toastService, 'showError')
    jest
      .spyOn(mailAccountService, 'listAll')
      .mockImplementation(() =>
        throwError(() => new Error('failed to load mail accounts'))
      )
    completeSetup(mailAccountService)
    expect(toastErrorSpy).toBeCalled()
  })

  it('should show errors on load if load mailRules failure', () => {
    const toastErrorSpy = jest.spyOn(toastService, 'showError')
    jest
      .spyOn(mailRuleService, 'listAll')
      .mockImplementation(() =>
        throwError(() => new Error('failed to load mail rules'))
      )
    completeSetup(mailRuleService)
    expect(toastErrorSpy).toBeCalled()
  })

  it('should support edit / create mail account, show error if needed', () => {
    completeSetup()
    let modal: NgbModalRef
    modalService.activeInstances.subscribe((refs) => (modal = refs[0]))
    component.editMailAccount(mailAccounts[0] as MailAccount)
    let editDialog = modal.componentInstance as MailAccountEditDialogComponent
    const toastErrorSpy = jest.spyOn(toastService, 'showError')
    const toastInfoSpy = jest.spyOn(toastService, 'showInfo')
    editDialog.failed.emit()
    expect(toastErrorSpy).toBeCalled()
    editDialog.succeeded.emit(mailAccounts[0])
    expect(toastInfoSpy).toHaveBeenCalledWith(
      `Saved account "${mailAccounts[0].name}".`
    )
    editDialog.cancel()
    component.editMailAccount()
  })

  it('should support delete mail account, show error if needed', () => {
    completeSetup()
    let modal: NgbModalRef
    modalService.activeInstances.subscribe((refs) => (modal = refs[0]))
    component.deleteMailAccount(mailAccounts[0] as MailAccount)
    const deleteDialog = modal.componentInstance as ConfirmDialogComponent
    const deleteSpy = jest.spyOn(mailAccountService, 'delete')
    const toastErrorSpy = jest.spyOn(toastService, 'showError')
    const toastInfoSpy = jest.spyOn(toastService, 'showInfo')
    const listAllSpy = jest.spyOn(mailAccountService, 'listAll')
    deleteSpy.mockReturnValueOnce(
      throwError(() => new Error('error deleting mail account'))
    )
    deleteDialog.confirm()
    expect(toastErrorSpy).toBeCalled()
    deleteSpy.mockReturnValueOnce(of(true))
    deleteDialog.confirm()
    expect(listAllSpy).toHaveBeenCalled()
    expect(toastInfoSpy).toHaveBeenCalledWith('Deleted mail account')
  })

  it('should support edit / create mail rule, show error if needed', () => {
    completeSetup()
    let modal: NgbModalRef
    modalService.activeInstances.subscribe((refs) => (modal = refs[0]))
    component.editMailRule(mailRules[0] as MailRule)
    const editDialog = modal.componentInstance as MailRuleEditDialogComponent
    const toastErrorSpy = jest.spyOn(toastService, 'showError')
    const toastInfoSpy = jest.spyOn(toastService, 'showInfo')
    editDialog.failed.emit()
    expect(toastErrorSpy).toBeCalled()
    editDialog.succeeded.emit(mailRules[0])
    expect(toastInfoSpy).toHaveBeenCalledWith(
      `Saved rule "${mailRules[0].name}".`
    )
    editDialog.cancel()
    component.editMailRule()
  })

  it('should support copy mail rule', () => {
    completeSetup()
    let modal: NgbModalRef
    modalService.activeInstances.subscribe((refs) => (modal = refs[0]))
    component.copyMailRule(mailRules[0] as MailRule)
    const editDialog = modal.componentInstance as MailRuleEditDialogComponent
    expect(editDialog.object.id).toBeNull()
    expect(editDialog.object.name).toEqual(`${mailRules[0].name} (copy)`)
    expect(editDialog.dialogMode).toEqual(EditDialogMode.CREATE)
  })

  it('should support delete mail rule, show error if needed', () => {
    completeSetup()
    let modal: NgbModalRef
    modalService.activeInstances.subscribe((refs) => (modal = refs[0]))
    component.deleteMailRule(mailRules[0] as MailRule)
    const deleteDialog = modal.componentInstance as ConfirmDialogComponent
    const deleteSpy = jest.spyOn(mailRuleService, 'delete')
    const toastErrorSpy = jest.spyOn(toastService, 'showError')
    const toastInfoSpy = jest.spyOn(toastService, 'showInfo')
    const listAllSpy = jest.spyOn(mailRuleService, 'listAll')
    deleteSpy.mockReturnValueOnce(
      throwError(() => new Error('error deleting mail rule'))
    )
    deleteDialog.confirm()
    expect(toastErrorSpy).toBeCalled()
    deleteSpy.mockReturnValueOnce(of(true))
    deleteDialog.confirm()
    expect(listAllSpy).toHaveBeenCalled()
    expect(toastInfoSpy).toHaveBeenCalledWith('Deleted mail rule')
  })

  it('should support edit permissions on mail rule objects', () => {
    completeSetup()
    const perms = {
      owner: 99,
      set_permissions: {
        view: {
          users: [1],
          groups: [2],
        },
        change: {
          users: [3],
          groups: [4],
        },
      },
    }
    let modal: NgbModalRef
    modalService.activeInstances.subscribe((refs) => (modal = refs[0]))
    const toastErrorSpy = jest.spyOn(toastService, 'showError')
    const toastInfoSpy = jest.spyOn(toastService, 'showInfo')
    const rulePatchSpy = jest.spyOn(mailRuleService, 'patch')
    component.editPermissions(mailRules[0] as MailRule)
    expect(modal).not.toBeUndefined()
    let dialog = modal.componentInstance as PermissionsDialogComponent
    expect(dialog.object).toEqual(mailRules[0])

    rulePatchSpy.mockReturnValueOnce(
      throwError(() => new Error('error saving perms'))
    )
    dialog.confirmClicked.emit({ permissions: perms, merge: true })
    expect(rulePatchSpy).toHaveBeenCalled()
    expect(toastErrorSpy).toHaveBeenCalled()
    rulePatchSpy.mockReturnValueOnce(of(mailRules[0] as MailRule))
    dialog.confirmClicked.emit({ permissions: perms, merge: true })
    expect(toastInfoSpy).toHaveBeenCalledWith('Permissions updated')

    modalService.dismissAll()
  })

  it('should support edit permissions on mail account objects', () => {
    completeSetup()
    const perms = {
      owner: 99,
      set_permissions: {
        view: {
          users: [1],
          groups: [2],
        },
        change: {
          users: [3],
          groups: [4],
        },
      },
    }
    let modal: NgbModalRef
    modalService.activeInstances.subscribe((refs) => (modal = refs[0]))
    const accountPatchSpy = jest.spyOn(mailAccountService, 'patch')
    component.editPermissions(mailAccounts[0] as MailAccount)
    expect(modal).not.toBeUndefined()
    let dialog = modal.componentInstance as PermissionsDialogComponent
    expect(dialog.object).toEqual(mailAccounts[0])
    dialog.confirmClicked.emit({ permissions: perms, merge: true })
    expect(accountPatchSpy).toHaveBeenCalled()
  })

  it('should update mail rule when enable is toggled', () => {
    completeSetup()
    const patchSpy = jest.spyOn(mailRuleService, 'patch')
    const toggleInput = fixture.debugElement.query(
      By.css('input[type="checkbox"]')
    )
    const toastErrorSpy = jest.spyOn(toastService, 'showError')
    const toastInfoSpy = jest.spyOn(toastService, 'showInfo')
    // fail first
    patchSpy.mockReturnValueOnce(
      throwError(() => new Error('Error getting config'))
    )
    toggleInput.nativeElement.click()
    expect(patchSpy).toHaveBeenCalled()
    expect(toastErrorSpy).toHaveBeenCalled()
    // succeed second
    patchSpy.mockReturnValueOnce(of(mailRules[0] as MailRule))
    toggleInput.nativeElement.click()
    patchSpy.mockReturnValueOnce(
      of({ ...mailRules[0], enabled: false } as MailRule)
    )
    toggleInput.nativeElement.click()
    expect(patchSpy).toHaveBeenCalled()
    expect(toastInfoSpy).toHaveBeenCalled()
  })
})
