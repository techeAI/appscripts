import { HttpClient } from '@angular/common/http'
import { Injectable } from '@angular/core'
import { Observable } from 'rxjs'
import { SystemStatus } from '../data/system-status'
import { environment } from 'src/environments/environment'

@Injectable({
  providedIn: 'root',
})
export class SystemStatusService {
  private endpoint = 'status'

  constructor(private http: HttpClient) {}

  get(): Observable<SystemStatus> {
    return this.http.get<SystemStatus>(
      `${environment.apiBaseUrl}${this.endpoint}/`
    )
  }
}
